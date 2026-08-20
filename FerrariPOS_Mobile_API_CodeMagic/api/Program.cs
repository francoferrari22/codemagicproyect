using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Data.Sqlite;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);
var jwtKey = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key missing");
var dbPath = builder.Configuration["FerrariPOS:DatabasePath"];
if (string.IsNullOrWhiteSpace(dbPath)) dbPath = Path.Combine(AppContext.BaseDirectory, "FerrarisPOS.db");
var cs = $"Data Source={dbPath};Mode=ReadOnly;Foreign Keys=True;";
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(o => o.TokenValidationParameters = new TokenValidationParameters { ValidateIssuer=false, ValidateAudience=false, ValidateLifetime=true, ValidateIssuerSigningKey=true, IssuerSigningKey=new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)) });
builder.Services.AddAuthorization();
var app = builder.Build();
app.UseAuthentication(); app.UseAuthorization();
app.MapGet("/health", () => Results.Ok(new { ok=true, service="FerrariPOS.Api" }));
app.MapPost("/api/auth/login", async (LoginRequest req) => {
    await using var db = new SqliteConnection(cs); await db.OpenAsync();
    await using var cmd = db.CreateCommand(); cmd.CommandText="SELECT id,username,full_name,role,password_hash FROM users WHERE username=$u AND active=1 LIMIT 1"; cmd.Parameters.AddWithValue("$u",req.Username);
    await using var rd=await cmd.ExecuteReaderAsync(); if(!await rd.ReadAsync()) return Results.Unauthorized();
    var stored=rd.GetString(4); // Existing FerrariPOS password hashes are validated by the desktop application; mobile login must use the same hashing routine before production.
    if (string.IsNullOrWhiteSpace(req.Password) || string.IsNullOrWhiteSpace(stored)) return Results.Unauthorized();
    // Temporary compatibility gate: replace with FerrariPOS Session/password verifier when the exact hashing implementation is wired.
    if (req.Password != Environment.GetEnvironmentVariable("FERRARIPOS_MOBILE_DEV_PASSWORD")) return Results.Unauthorized();
    var claims=new[]{new Claim(JwtRegisteredClaimNames.Sub,rd.GetInt64(0).ToString()),new Claim(ClaimTypes.Name,rd.GetString(1)),new Claim(ClaimTypes.Role,rd.GetString(3))};
    var token=new JwtSecurityToken(claims:claims,expires:DateTime.UtcNow.AddHours(12),signingCredentials:new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),SecurityAlgorithms.HmacSha256));
    return Results.Ok(new { token=new JwtSecurityTokenHandler().WriteToken(token), user=rd.GetString(2), role=rd.GetString(3) });
});
app.MapGet("/api/dashboard", async (HttpContext _) => Results.Ok(new {
 salesToday=await Scalar("SELECT COALESCE(SUM(total),0) FROM sales WHERE date(created_at)=date('now','localtime') AND status='COMPLETED'"),
 ticketsToday=await Scalar("SELECT COUNT(*) FROM sales WHERE date(created_at)=date('now','localtime') AND status='COMPLETED'"),
 totalCredit=await Scalar("SELECT COALESCE(SUM(CASE WHEN entry_type IN ('CHARGE','SALE','DEBIT') THEN amount ELSE -amount END),0) FROM customer_accounts"),
 lowStock=await Scalar("SELECT COUNT(*) FROM products WHERE active=1 AND stock<=min_stock")
})).RequireAuthorization();
app.MapGet("/api/products", async()=>Results.Ok(await Query("SELECT id,barcode,description AS name,sale_price AS price,stock,min_stock,category,unit FROM products WHERE active=1 ORDER BY description"))).RequireAuthorization();
app.MapGet("/api/customers", async()=>Results.Ok(await Query("SELECT id,name,document,phone,email,credit_limit FROM customers WHERE active=1 ORDER BY name"))).RequireAuthorization();
app.MapGet("/api/sales", async()=>Results.Ok(await Query("SELECT id,ticket_no AS ticketNo,total,payment_method AS paymentMethod,status,created_at AS createdAt FROM sales ORDER BY id DESC LIMIT 200"))).RequireAuthorization();
app.MapGet("/api/credits", async()=>Results.Ok(await Query("SELECT c.id,c.name,COALESCE(SUM(CASE WHEN a.entry_type IN ('CHARGE','SALE','DEBIT') THEN a.amount ELSE -a.amount END),0) AS balance FROM customers c LEFT JOIN customer_accounts a ON a.customer_id=c.id WHERE c.active=1 GROUP BY c.id,c.name HAVING balance<>0 ORDER BY c.name"))).RequireAuthorization();
app.MapGet("/api/cash", async()=>Results.Ok(await Query("SELECT id,user_id AS userId,opened_at AS openedAt,closed_at AS closedAt,opening_amount AS openingAmount,closing_amount AS closingAmount,status FROM cash_sessions ORDER BY id DESC LIMIT 100"))).RequireAuthorization();
app.Run();
async Task<object?> Scalar(string sql){await using var db=new SqliteConnection(cs);await db.OpenAsync();await using var c=db.CreateCommand();c.CommandText=sql;return await c.ExecuteScalarAsync();}
async Task<List<Dictionary<string,object?>>> Query(string sql){var list=new List<Dictionary<string,object?>>();await using var db=new SqliteConnection(cs);await db.OpenAsync();await using var c=db.CreateCommand();c.CommandText=sql;await using var r=await c.ExecuteReaderAsync();while(await r.ReadAsync()){var row=new Dictionary<string,object?>();for(int i=0;i<r.FieldCount;i++)row[r.GetName(i)]=r.IsDBNull(i)?null:r.GetValue(i);list.Add(row);}return list;}
record LoginRequest(string Username,string Password);
