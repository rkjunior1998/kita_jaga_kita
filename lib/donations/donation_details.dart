import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/widgets/comments_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../services/global_methods.dart';
import 'donations_screen.dart';

class DonationDetailsScreen extends StatefulWidget {
  const DonationDetailsScreen({required this.uploadedBy, required this.donationID});
  final String uploadedBy;
  final String donationID;

  @override
  _DonationDetailsScreenState createState() => _DonationDetailsScreenState();
}

class _DonationDetailsScreenState extends State<DonationDetailsScreen> {
  
  TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isCommenting = false;
  String? authorName;
  String? userImageUrl;
  String? donationCategory;
  String? donationDescription;
  String? donationTitle;
  bool? recruitment;
  Timestamp? postedDateTimeStamp;
  Timestamp? deadlineDateTimeStamp;
  String? postedDate;
  String? deadlineDate;
  String locationCompany = "";
  String emailCompany = "";
  int applicants = 0;
  bool isDeadlineAvailable = false;
  bool showComment = false;

  @override
  void initState() {
    super.initState();
    getDonationData();
  }

  applyForDonation(){
    final Uri params = Uri(
      scheme: 'mailto',
      path: emailCompany,
      query: 'subject=Applying for $donationTitle&body=Hello, please send or attach your personal information',
    );
    final url = params.toString();
    launch(url);
    addNewApplicant();
  }

  void addNewApplicant() async{
    var docRef = FirebaseFirestore.instance.collection('donations').doc(widget.donationID);

    docRef.update({
      "applicants": applicants + 1,
    });

    Navigator.pop(context);
  }
  
  void getDonationData() async{
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uploadedBy)
        .get();
    
    if(userDoc == null){
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot donationDatabase = await FirebaseFirestore.instance
    .collection('donations')
    .doc(widget.donationID)
    .get();

    if(donationDatabase == null){
      return;
    } else{
      setState(() {
        donationTitle = donationDatabase.get('donationTitle');
        donationDescription = donationDatabase.get('donationDescription');
        recruitment = donationDatabase.get('recruitment');
        emailCompany = donationDatabase.get('email');
        locationCompany = donationDatabase.get('location');
        applicants = donationDatabase.get('applicants');
        postedDateTimeStamp = donationDatabase.get('createdAt');
        deadlineDateTimeStamp = donationDatabase.get('deadLineDateTimeStamp');
        deadlineDate = donationDatabase.get('deadlineDate');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.year}-${postDate.month}-${postDate.day}';
      });
      
      var date = deadlineDateTimeStamp!.toDate();
      isDeadlineAvailable = date.isAfter(DateTime.now());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close, size: 40, color: Colors.grey),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DonationScreen()));
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white30,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          donationTitle == null ? '' : donationTitle!,
                          maxLines: 3,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3,
                                color: Colors.grey,
                              ),
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                image: NetworkImage(
                                  userImageUrl == null
                                      ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                                      : userImageUrl!,
                                ),
                                fit: BoxFit.fill
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName == null ? '' :authorName!,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  locationCompany,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            applicants.toString(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(width: 6,),
                          Text(
                            'Applicants',
                            style: TextStyle(color: Colors.grey,),
                          ),
                          SizedBox(width: 10,),
                          Icon(
                            Icons.how_to_reg_sharp,
                            color: Colors.grey,
                          )
                        ],
                      ),

                      FirebaseAuth.instance.currentUser!.uid != widget.uploadedBy ? Container() :
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              dividerWidget(),
                              Text(
                                'Recruitment:',
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                      onPressed: (){
                                        User? user = _auth.currentUser;
                                        final _uid = user!.uid;
                                        if(_uid == widget.uploadedBy){
                                          try{
                                            FirebaseFirestore.instance
                                                .collection('donations')
                                                .doc(widget.donationID)
                                                .update({'recruitment': true});
                                          } catch(err){
                                            GlobalMethod.showErrorDialog(
                                              error: 'Action cant be performed',
                                              ctx: context
                                            );
                                          }
                                        } else{
                                          GlobalMethod.showErrorDialog(
                                              error: 'You cant perform this action!',
                                              ctx: context
                                          );
                                        }
                                        getDonationData();
                                      },
                                      child: Text(
                                        'ON',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal
                                        ),
                                      ),
                                  ),
                                  Opacity(
                                    opacity: recruitment == true ? 1 : 0,
                                    child: Icon(
                                      Icons.check_box,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      User? user = _auth.currentUser;
                                      final _uid = user!.uid;
                                      if(_uid == widget.uploadedBy){
                                        try{
                                          FirebaseFirestore.instance
                                              .collection('donations')
                                              .doc(widget.donationID)
                                              .update({'recruitment': false});
                                        } catch(err){
                                          GlobalMethod.showErrorDialog(
                                              error: 'Action cant be performed',
                                              ctx: context
                                          );
                                        }
                                      } else{
                                        GlobalMethod.showErrorDialog(
                                            error: 'You cant perform this action!',
                                            ctx: context
                                        );
                                      }
                                      getDonationData();
                                    },
                                    child: Text(
                                      'OFF',
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal
                                      ),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: recruitment == false ? 1 : 0,
                                    child: Icon(
                                      Icons.check_box,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      dividerWidget(),
                      Text(
                        'Donation Description:',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        donationDescription == null ? '' : donationDescription!,
                        textAlign: TextAlign.justify,
                        style: TextStyle(fontSize: 14, color: Colors.grey,),
                      ),
                      dividerWidget(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white30,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10,),
                      Center(
                        child: Text(
                          isDeadlineAvailable
                        ? 'Accepting Donations:'
                              : ' Deadline Passed away.',
                          style: TextStyle(
                            color: isDeadlineAvailable
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.normal,
                            fontSize: 16
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Center(
                        child: MaterialButton(
                          onPressed: (){
                            applyForDonation();
                          },
                          color: Colors.blueAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Donate Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                              ),
                            ),
                          ),
                        ),
                      ),
                      dividerWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploaded on:',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            postedDate == null ? '' : postedDate!,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deadline date:',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            deadlineDate == null ? '' : deadlineDate!,
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                      dividerWidget(),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                color: Colors.white30,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(
                          milliseconds: 500,
                        ),
                        child: _isCommenting
                            ?
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                    flex: 3,
                                    child: TextField(
                                      controller: _commentController,
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.pink),
                                        ),
                                      ),
                                    ),
                                ),
                                Flexible(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: MaterialButton(
                                            onPressed: () async{
                                              if(_commentController.text.length < 3){
                                                GlobalMethod.showErrorDialog(
                                                    error: 'Comment cant be less than 3 characters',
                                                    ctx: context
                                                );
                                              } else{
                                                final _generateId = Uuid().v4();
                                                await FirebaseFirestore.instance
                                                .collection('donations')
                                                .doc(widget.donationID)
                                                .update({
                                                  'donationComments':
                                                      FieldValue.arrayUnion([
                                                        {
                                                          'userId': FirebaseAuth.instance.currentUser!.uid,
                                                          'commentId': _generateId,
                                                          'name': name,
                                                          'userImageUrl': userImage,
                                                          'commentBody': _commentController.text,
                                                          'time': Timestamp.now(),
                                                        }
                                                      ]),
                                                });
                                                await Fluttertoast.showToast(
                                                    msg:
                                                    "Your comment has been added",
                                                  toastLength: Toast.LENGTH_LONG,
                                                  backgroundColor: Colors.grey,
                                                  fontSize: 18.0
                                                );
                                                _commentController.clear();
                                              }
                                              setState(() {
                                                showComment = true;
                                              });
                                            },
                                            color: Colors.blueAccent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Text(
                                              'Post',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: (){
                                              setState(() {
                                                _isCommenting = !_isCommenting;
                                                showComment = false;
                                              });
                                            },
                                            child: Text('Cancel')
                                        ),
                                      ],
                                    )
                                )
                              ],
                            )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    _isCommenting = !_isCommenting;
                                  });
                                },
                                icon: Icon(
                                  Icons.add_comment,
                                  color: Colors.blueAccent,
                                  size: 40,
                                ),
                            ),
                            SizedBox(width: 10,),
                            IconButton(
                              onPressed: (){
                                setState(() {
                                  showComment = true;
                                });
                              },
                              icon: Icon(
                                Icons.arrow_drop_down_circle,
                                color: Colors.blueAccent,
                                size: 40,
                              ),
                            ),

                          ],
                        ),
                      ),
                      showComment == false ? Container() :
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                              .collection('donations')
                              .doc(widget.donationID)
                              .get(),
                              builder: (context, snapshot){
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return Center(child: CircularProgressIndicator());
                                }else{
                                  if(snapshot.data == null){
                                    Center(child: Text('No comment for this job'));
                                  }
                                }
                                return ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index){
                                      return CommentWidget(
                                          commentId: snapshot.data!['donationComments'] [index]['commentId'],
                                          commenterId: snapshot.data!['donationComments'] [index]['userId'],
                                          commenterName: snapshot.data!['donationComments'] [index]['name'],
                                          commentBody: snapshot.data!['donationComments'] [index]['commentBody'],
                                          commenterImageUrl: snapshot.data!['donationComments'] [index]['userImageUrl']
                                      );
                                    },
                                    separatorBuilder: (context, index){
                                      return Divider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      );
                                    },
                                    itemCount: snapshot.data!['donationComments'].length
                                );
                              },
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dividerWidget(){
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }
}














