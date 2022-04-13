import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:linkedin_clone/services/global_variables.dart';
import 'package:linkedin_clone/widgets/bottomNavBar.dart';
import 'package:uuid/uuid.dart';

import '../pesistent/persistent.dart';
import '../services/global_methods.dart';

class UploadDonationNow extends StatefulWidget {
  const UploadDonationNow({Key? key}) : super(key: key);

  @override
  _UploadDonationNowState createState() => _UploadDonationNowState();
}

class _UploadDonationNowState extends State<UploadDonationNow> {

  TextEditingController _donationCategoryController = TextEditingController(text: 'Select Donation Category');
  TextEditingController _donationTitleController = TextEditingController();
  TextEditingController _donationDescriptionController = TextEditingController();
  TextEditingController _deadlineDateController = TextEditingController(text: 'Donation Deadline Date');

  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  Timestamp? deadlineDateTimeStamp;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _donationCategoryController.dispose();
    _donationTitleController.dispose();
    _donationDescriptionController.dispose();
    _deadlineDateController.dispose();
  }

  void _uploadDonation() async{
    final donationId = Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if(isValid){
      if(_deadlineDateController.text == 'Choose donation Deadline date' || _donationCategoryController.text == 'Choose donation category'){
        GlobalMethod.showErrorDialog(
          error: 'Please pick everything', ctx: context
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try{
        await FirebaseFirestore.instance.collection('donations').doc(donationId).set({
          'donationId': donationId,
          'uploadedBy': _uid,
          'email': user.email,
          'donationTitle': _donationTitleController.text,
          'donationDescription': _donationDescriptionController.text,
          'deadlineDate': _deadlineDateController.text,
          'deadLineDateTimeStamp': deadlineDateTimeStamp,
          'donationCategory': _donationCategoryController.text,
          'donationComments': [],
          'recruitment': true,
          'createdAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'location': location,
          'applicants': 0,
        });
        await Fluttertoast.showToast(
          msg: "The donation has been uploaded",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0
        );
        _donationTitleController.clear();
        _donationDescriptionController.clear();
        setState(() {
          _donationCategoryController.text = 'Choose donation category';
          _deadlineDateController.text = 'Choose donation Deadline date';
        });
      } catch(error){} finally{
        setState(() {
          _isLoading = false;
        });
      }
    } else{
      print('It is not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 2,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Card(
            color: Colors.white10,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Please fill in all fields',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textTitles(label: "Donation Category :"),
                          _textFormFields(
                              valueKey: 'DonationCategory', 
                              controller: _donationCategoryController, 
                              enabled: false, 
                              fct: (){
                                _showDonationCategoriesDialog(size: size);
                              }, 
                              maxLength: 100,
                          ),
                          _textTitles(label: 'Donation Title : '),
                          _textFormFields(
                              valueKey: 'DonationTitle',
                              controller: _donationTitleController,
                              enabled: true,
                              fct: (){},
                              maxLength: 100
                          ),
                          _textTitles(label: 'Donation Description : '),
                          _textFormFields(
                              valueKey: 'DonationDescription',
                              controller: _donationDescriptionController,
                              enabled: true,
                              fct: (){},
                              maxLength: 100
                          ),
                          _textTitles(label: 'Donation Deadline Date : '),
                          _textFormFields(
                              valueKey: 'DonationDeadLine',
                              controller: _deadlineDateController,
                              enabled: false,
                              fct: (){
                                _pickDateDialog();
                              },
                              maxLength: 100
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: _isLoading ? CircularProgressIndicator() : MaterialButton(
                        onPressed: _uploadDonation,
                        color: Colors.black,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13)
                        ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Post Now',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.upload_file,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength
  }) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
          onTap: (){
            fct();
          },
          child: TextFormField(
            validator: (value) {
              if(value!.isEmpty){
                return "Value is missing";
              }
              return null;
            },
            controller: controller,
            enabled: enabled,
            key: ValueKey(valueKey),
            style: TextStyle(
              color: Colors.white,
            ),
            maxLines: valueKey == 'DonationDescription' ? 3 : 1,
            maxLength: maxLength,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white10),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
    );
  }

  _showDonationCategoriesDialog({required Size size}){
    showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Donation Category',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Persistent.donationCategoryList.length,
                  itemBuilder: (ctxx, index){
                    return InkWell(
                      onTap: (){
                        setState(() {
                          _donationCategoryController.text = Persistent.donationCategoryList[index];
                        });
                        Navigator.pop(context);
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
                                  fontSize: 16,
                                ),
                              ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ],
          );
        }
    );
  }

  void _pickDateDialog() async{
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(
          Duration(days: 0),
        ),
        lastDate: DateTime(2100),
    );

    if (picked != null){
      setState(() {
        _deadlineDateController.text = '${picked!.year}-${picked!.month}-${picked!.day}';
        deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(picked!.microsecondsSinceEpoch);
      });
    }
  }

  Widget _textTitles({required String label}){
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.bold,

          ),
        ),
    );
  }
}
