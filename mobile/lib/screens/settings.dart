import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget { const SettingsScreen({super.key}); @override State<SettingsScreen> createState()=>_SettingsScreenState(); }
class _SettingsScreenState extends State<SettingsScreen>{
 final url=TextEditingController(); final user=TextEditingController(); final pass=TextEditingController(); bool busy=false; String? msg;
 @override void initState(){super.initState();url.text=api.baseUrl;}
 Future<void> save() async { setState(()=>busy=true); try { await api.save(url.text); final r=await api.post('/api/auth/login',{'username':user.text.trim(),'password':pass.text}); await api.setToken(r['token'] as String); if(mounted) Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const HomeScreen())); } catch(e){setState(()=>msg='$e');} finally{if(mounted)setState(()=>busy=false);} }
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Conexión FerrariPOS')),body:ListView(padding:const EdgeInsets.all(20),children:[const Text('Servidor API',style:TextStyle(fontSize:26,fontWeight:FontWeight.bold)),const SizedBox(height:10),const Text('Ejemplo: http://192.168.1.50:5080'),const SizedBox(height:18),TextField(controller:url,decoration:const InputDecoration(labelText:'URL de la API',border:OutlineInputBorder())),const SizedBox(height:12),TextField(controller:user,decoration:const InputDecoration(labelText:'Usuario',border:OutlineInputBorder())),const SizedBox(height:12),TextField(controller:pass,obscureText:true,decoration:const InputDecoration(labelText:'Contraseña',border:OutlineInputBorder())),const SizedBox(height:18),if(msg!=null)Text(msg!,style:const TextStyle(color:Colors.redAccent)),const SizedBox(height:10),FilledButton.icon(onPressed:busy?null:save,icon:const Icon(Icons.login),label:Text(busy?'Conectando...':'Guardar y conectar'))]));
}
