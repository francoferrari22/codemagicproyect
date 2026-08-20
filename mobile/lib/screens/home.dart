import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'list_screen.dart';
import 'settings.dart';
class HomeScreen extends StatefulWidget{const HomeScreen({super.key});@override State<HomeScreen> createState()=>_HomeScreenState();}
class _HomeScreenState extends State<HomeScreen>{Map<String,dynamic>? d;String? error;bool loading=true;final money=NumberFormat.currency(locale:'es_AR',symbol:r'$ ',decimalDigits:2);
 Future<void> load()async{setState(()=>loading=true);try{d=Map<String,dynamic>.from(await api.get('/api/dashboard'));error=null;}catch(e){error='$e';}finally{if(mounted)setState(()=>loading=false);}}
 @override void initState(){super.initState();load();}
 Widget metric(String t,String v,IconData i)=>Card(child:ListTile(leading:CircleAvatar(child:Icon(i)),title:Text(t),subtitle:Text(v,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold))));
 Widget menu(BuildContext c,String t,String s,String path,IconData i)=>Card(child:ListTile(leading:Icon(i),title:Text(t),subtitle:Text(s),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>ListScreen(path:path,title:t)))));
 @override Widget build(BuildContext c){return Scaffold(appBar:AppBar(title:const Text("Ferrari's POS Mobile"),actions:[IconButton(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>const SettingsScreen())),icon:const Icon(Icons.settings))]),body:RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(14),children:[const Text('Resumen',style:TextStyle(fontSize:28,fontWeight:FontWeight.bold)),const SizedBox(height:12),if(loading)const LinearProgressIndicator(),if(error!=null)Text(error!),if(d!=null)...[metric('Ventas de hoy',money.format(d!['salesToday']??0),Icons.point_of_sale),metric('Tickets de hoy','${d!['ticketsToday']??0}',Icons.receipt),metric('Crédito pendiente',money.format(d!['totalCredit']??0),Icons.credit_card),metric('Stock bajo','${d!['lowStock']??0}',Icons.inventory_2)],menu(c,'Ventas','Tickets y ventas','/api/sales',Icons.receipt_long),menu(c,'Clientes','Clientes y cuentas','/api/customers',Icons.people),menu(c,'Inventario','Productos y existencias','/api/products',Icons.inventory),menu(c,'Caja','Sesiones y movimientos','/api/cash',Icons.account_balance),menu(c,'Créditos','Saldos pendientes','/api/credits',Icons.account_balance_wallet)]));}
}
