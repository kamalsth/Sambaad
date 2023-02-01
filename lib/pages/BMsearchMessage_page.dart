import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


List<DocumentSnapshot> searchForMessage(String searchText, QuerySnapshot snapshot) {
  List<DocumentSnapshot> result = [];
  for (final DocumentSnapshot message in snapshot.docs) {
    if (BoyerMoore(searchText, message.get('message'))) {
      result.add(message);
    }
  }
  return result;
}

bool BoyerMoore(String searchText, String message) {
  int n = message.length;
  int m = searchText.length;
  List<int> right = List.filled(256, -1);

  for (int j = 0; j < m; j++) {
    right[searchText.codeUnitAt(j)] = j;
  }

  int skip;
  for (int i = 0; i <= n - m; i += skip) {
    skip = 0;
    for (int j = m - 1; j >= 0; j--) {
      if (searchText[j] != message[i + j]) {
        skip = max(1, j - right[message.codeUnitAt(i + j)]);
        break;
      }
    }
    if (skip == 0) {
      return true;
    }
  }
  return false;
}


class BMsearchMessage extends StatefulWidget {
  final String groupId;

  const BMsearchMessage({Key?key,
  required this.groupId,

  }):super(key:key);

  @override
  State<BMsearchMessage> createState() => _BMsearchMessageState();
}

class _BMsearchMessageState extends State<BMsearchMessage> {
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
    return   Scaffold(
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
                       if (searchController.text.isNotEmpty) {
                          setState(() {
                          isLoading = true;
                        });
                       await FirebaseFirestore.instance
                        .collection("groups").doc(widget.groupId).collection("messages")
                        .get().then((snapshot){
                          setState(() {
                              searchSnapshot = snapshot;
                              hasUserSearched = true;
                              isLoading = false;
                            });
                        
                        });
                
                       }
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
                :searchSnapshot != null &&
                  searchSnapshot!.docs.isNotEmpty &&
                  hasUserSearched
                    ? ListView.builder(
                        itemCount: searchForMessage(searchController.text, searchSnapshot!).length,
                        itemBuilder: (context, index) {
                          final DocumentSnapshot message = searchForMessage(searchController.text, searchSnapshot!)[index];
                          
                          return ListTile(
            
                            title: Text(message.get('message')),
                          );
                        },
                      )
                    :Container(), 
                    
          ),
          
        ],
      ),
    );
  }
}