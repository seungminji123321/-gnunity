import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/club_model.dart';
import 'package:gnunity/screens/club_detail_screen.dart';
//동아리 검색
class SearchScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
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
          TextField(// 검색창
            decoration: const InputDecoration(
              hintText: '동아리 이름을 검색하세요.',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded( //검색결과
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchQuery.isEmpty
                  ? FirebaseFirestore.instance.collection('clubs').snapshots()
                  : FirebaseFirestore.instance
                  .collection('clubs')
                  .where('name', isGreaterThanOrEqualTo: _searchQuery)
                  .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('검색 결과가 없습니다.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var clubDoc = snapshot.data!.docs[index];
                    var clubData = clubDoc.data() as Map<String, dynamic>;

                    return Card( //검색된 동아리
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(clubData['name'] ?? '이름 없음'),
                        subtitle: Text(clubData['description'] ?? '소개 없음', maxLines: 1, overflow: TextOverflow.ellipsis),

                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ClubDetailScreen(
                                club: Club(
                                  id: clubDoc.id,
                                  name: clubData['name'] ?? '이름 없음',
                                  description: clubData['description'] ?? '소개 없음',
                                  members: List<String>.from(clubData['members'] ?? []),
                                  recruiting: clubData['recruiting'] ?? false,
                                  joinPassword: clubData['joinPassword'] ?? '',

                                ),
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