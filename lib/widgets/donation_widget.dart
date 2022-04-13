import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedin_clone/donations/donation_details.dart';
import 'package:linkedin_clone/services/global_methods.dart';

class DonationWidget extends StatefulWidget {

  final String donationTitle;
  final String donationDescription;
  final String donationId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final bool recruitment;
  final String email;
  final String location;



  const DonationWidget({
    required this.donationTitle,
    required this.donationDescription,
    required this.donationId,
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.recruitment,
    required this.email,
    required this.location
  });

  @override
  _DonationWidgetState createState() => _DonationWidgetState();
}

class _DonationWidgetState extends State<DonationWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) =>
                  DonationDetailsScreen(
                    uploadedBy: widget.uploadedBy,
                    donationID: widget.donationId,
                  )));
        },
        onLongPress: ()=> _deleteDialog(),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: Image.network(widget.userImage),
        ),
        title: Text(
          widget.donationTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8,),
            Text(
              widget.donationDescription,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.grey,
        ),
      ),
    );
  }

  _deleteDialog(){
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
           actions: [
             TextButton(
               onPressed: () async{
                 try{
                   if (widget.uploadedBy == _uid){
                     await FirebaseFirestore.instance
                         .collection('donations')
                         .doc(widget.donationId)
                         .delete();
                     await Fluttertoast.showToast(msg: "Donation has been deleted.",
                     toastLength: Toast.LENGTH_LONG,
                       backgroundColor: Colors.grey,
                       fontSize: 10.0,
                     );
                     Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                   }
                   else {
                     GlobalMethod.showErrorDialog(error: "You cannot perform this action", ctx: ctx);
                   }
                 }
                 catch (error){
                   GlobalMethod.showErrorDialog(error: "This donation can't be deleted", ctx: context);
                 } finally{}
               },
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(
                     Icons.delete,
                     color: Colors.red,
                   ),
                   Text(
                     'Delete',
                     style: TextStyle(color: Colors.red),
                   )
                 ],
               ),
             )
           ],
          );
        });
  }
}