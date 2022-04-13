import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/pesistent/persistent.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/widgets/bottomNavBar.dart';

import '../search/search_donation.dart';
import '../widgets/donation_widget.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {

  String? donationCategoryFilter;

  void getMyData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();

    setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
      location = userDoc.get('location');
    });
  }

  @override
  void initState(){
    super.initState();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0,),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.filter_list_outlined, color: Colors.grey),
          onPressed: (){},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined, color: Colors.grey),
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => SearchScreen()));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
          .collection('donations')
          .where('donationCategory', isEqualTo: donationCategoryFilter)
          .where('recruitment', isEqualTo: true)
          .orderBy('createdAt', descending: false)
          .snapshots(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          else if(snapshot.connectionState == ConnectionState.active){
            if(snapshot.data?.docs.isNotEmpty == true){
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index){
                    return DonationWidget(
                        donationTitle: snapshot.data?.docs[index]['donationTitle'],
                        donationDescription: snapshot.data?.docs[index]['donationDescription'],
                        donationId: snapshot.data?.docs[index]['donationId'],
                        uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                        userImage: snapshot.data?.docs[index]['userImage'],
                        name: snapshot.data?.docs[index]['name'],
                        recruitment: snapshot.data?.docs[index]['recruitment'],
                        email: snapshot.data?.docs[index]['email'],
                        location: snapshot.data?.docs[index]['location']
                    );
                  }
              );
            } else{
              return Center(
                child: Text('There is no donations'),
              );
            }
          }
          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
            )
          );
        }
      )
    );
  }

  _showDonationCategoryDialog({required Size size}){
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Job Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                itemCount: Persistent.donationCategoryList.length,
                  itemBuilder: (ctxx, index){
                    return InkWell(
                      onTap: (){
                        setState(() {
                          donationCategoryFilter = Persistent.donationCategoryList[index];
                        });
                        Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                        print(
                          'donationCategoryList[index], ${Persistent.donationCategoryList[index]}'
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_right_outlined,
                            color: Colors.grey,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Persistent.donationCategoryList[index],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontStyle: FontStyle.italic
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                  },
                  child: Text('Close', style: TextStyle(color: Colors.white),),
              ),
              TextButton(
                onPressed: (){
                  setState(() {
                    donationCategoryFilter = null;
                  });
                  Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                },
                child: Text('Cancel Filter', style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        }
    );
  }
}






















