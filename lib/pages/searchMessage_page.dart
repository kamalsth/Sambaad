import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchMessage extends StatefulWidget {
  final String groupId;


  const SearchMessage({Key?key,
  required this.groupId,

  }):super(key:key);
  

  @override
  State<SearchMessage> createState() => _SearchMessageState();
}

class _SearchMessageState extends State<SearchMessage> {
  Stream? groups;
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;
  






  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Search",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search message....",
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final QuerySnapshot searchResults = await FirebaseFirestore.instance
                      .collection("groups").doc(widget.groupId).collection("messages").where('message', isEqualTo: searchController.text)
                      .get();
                  setState(() {
                    searchSnapshot = searchResults;
                    hasUserSearched = true;
                    isLoading = false;
                  });
                },
                  
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),


          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : searchSnapshot != null &&
                        searchSnapshot!.docs.isNotEmpty &&
                        hasUserSearched
                    ? ListView.builder(
                        itemCount: searchSnapshot!.docs.length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot message = searchSnapshot!.docs[index];
                          return ListTile(
                            title: Text(message.get('message')),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No results found",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
          ),
          
        ],
      ),
    );
  }
}