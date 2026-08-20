import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
class ListScreen extends StatefulWidget{final String path,title;const ListScreen({super.key,required this.path,required this.title});@override State<ListScreen> createState()=>_ListScreenState();}
class _ListScreenState extends State<ListScreen>{List<dynamic> rows=[];bool loading=true;String? error;final money=NumberFormat.currency(locale:'es_AR',symbol:r'$ ',decimalDigits:2);
 Future<void> load()async{try{final d=await api.get(widget.path);final x=d is List?d:(d['items']??d['sessions']??d['movements']??[]);setState(()=>rows=List.from(x));}catch(e){setState(()=>error='$e');}finally{if(mounted)setState(()=>loading=false);}}
 @override void initState(){super.initState();load();}
 String val(dynamic v)=>v is num?money.format(v):'${v??''}';
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(widget.title)),body:loading?const Center(child:CircularProgressIndicator()):error!=null?Center(child:Text(error!)):rows.isEmpty?const Center(child:Text('No hay datos')):ListView.separated(padding:const EdgeInsets.all(12),itemCount:rows.length,itemBuilder:(c,i){final r=Map<String,dynamic>.from(rows[i]);final name=r['customer']??r['name']??r['description']??r['concept']??'Registro';final amount=r['total']??r['balance']??r['amount']??r['stock'];return Card(child:ListTile(title:Text('$name'),subtitle:Text(r['createdAt']?.toString()??r['created_at']?.toString()??''),trailing:amount!=null?Text(val(amount)):null));},separatorBuilder:(_,__)=>const SizedBox(height:6)));
}
