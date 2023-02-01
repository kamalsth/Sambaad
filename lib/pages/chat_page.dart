import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sambaad/pages/group_info.dart';
import 'package:sambaad/pages/searchMessage_page.dart';
import 'package:sambaad/services/database_services.dart';
import 'package:sambaad/widgets/message_tile.dart';
import 'package:sambaad/widgets/widgets.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AESEncryption {
  static encryptAES(plainText) {
    final key = encrypt.Key.fromUtf8('JaNdRgUkXp2s5v8y/B?E(H+MbQeShVmY');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;

  }

  static decryptAES(encryptedText) {
    final key = encrypt.Key.fromUtf8('JaNdRgUkXp2s5v8y/B?E(H+MbQeShVmY');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage({Key?key,
  required this.groupId,
  required this.groupName,
  required this.userName,
  
  }):super(key:key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>?chats;
  TextEditingController messageController=TextEditingController();
  String admin="";

  @override
  void initState(){
    getChatandAdmin();
    super.initState();
  }

  getChatandAdmin(){
    DatabaseServices().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseServices().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       centerTitle: true,
       elevation: 0,
       title: Text(widget.groupName),
       backgroundColor: Theme.of(context).primaryColor,       
        actions: [
          IconButton(onPressed:(){
            nextScreen(context, SearchMessage());
          }, icon: const Icon(Icons.search)),


          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfo(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      adminName: admin,
                      userName: widget.userName,
                    ));
              },
              icon: const Icon(Icons.info))       
        ],
      ),
      

      body: Column(
        children: <Widget>[

          // chat messages here 
        Expanded(child: chatMessages()), // chatMessages() calling,

          Container(
            
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.white, fontSize: 15),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.send,
                      color: Colors.white,
                    )),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
              reverse: true,    //update

                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                     // message: snapshot.data.docs[index]['message'],
                      message: AESEncryption.decryptAES(snapshot.data.docs[index]['message']),
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data.docs[index]['sender'],
                        
                          );
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
       // "message": messageController.text,
        "message": AESEncryption.encryptAES(messageController.text),
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseServices().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}