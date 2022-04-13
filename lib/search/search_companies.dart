import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linkedin_clone/widgets/bottomNavBar.dart';

import '../widgets/all_companies_widget.dart';

class AllDonationsScreen extends StatefulWidget {
  @override
  _AllDonationsScreenState createState() => _AllDonationsScreenState();
}

class _AllDonationsScreenState extends State<AllDonationsScreen> {

  TextEditingController _searchQueryController = TextEditingController();
  String searchQuery = 'Search query';

  Widget _buildSearchField(){
    return TextField(
      controller: _searchQueryController,
      autocorrect: true,
      decoration: InputDecoration(
        hintText: "Search for users...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions(){
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: (){
          _clearSearchQuery();
        },
      )
    ];
  }

  void updateSearchQuery(String newQuery){
    setState(() {
      searchQuery = newQuery;
      print(searchQuery);
    });
  }

  void _clearSearchQuery(){
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarForApp(indexNum: 1,),
      appBar: AppBar(
        backgroundColor: Colors.white10,
        automaticallyImplyLeading: false,
        title: _buildSearchField(),
        actions: _buildActions(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users')
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .snapshots(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          } else if(snapshot.connectionState == ConnectionState.active){
            if(snapshot.data!.docs.isNotEmpty){
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index){
                  return AllCompaniesWidget(
                    userID: snapshot.data!.docs[index]['id'],
                    userName: snapshot.data!.docs[index]['name'],
                    userEmail: snapshot.data!.docs[index]['email'],
                    phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                    userImageURL: snapshot.data!.docs[index]['userImage'],
                  );
                }
              );
            } else {
              return Center(
                child: Text('There is no users'),
              );
            }
          }
          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          );
        },
      ),
    );
  }
}












































