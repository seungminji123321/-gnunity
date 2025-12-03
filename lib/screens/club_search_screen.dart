import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/club_model.dart';
import 'package:gnunity/models/user_model.dart';
import 'package:gnunity/screens/club_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final User currentUser;
  const SearchScreen({super.key, required this.currentUser});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: '동아리 검색', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
            onChanged: (value) => setState(() => _searchQuery = value.trim()),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchQuery.isEmpty
                  ? FirebaseFirestore.instance.collection('clubs').snapshots()
                  : FirebaseFirestore.instance.collection('clubs').where('name', isGreaterThanOrEqualTo: _searchQuery).where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Center(child: Text('검색 결과 없음'));

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    // Club.fromMap 사용하여 Club 객체 생성
                    final club = Club.fromMap(snapshot.data!.docs[index].data() as Map<String, dynamic>, snapshot.data!.docs[index].id);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(club.name),
                        subtitle: Text(club.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ClubDetailScreen(
                                club: club,
                                currentUser: widget.currentUser,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}