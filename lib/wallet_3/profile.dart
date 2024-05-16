import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/a/ACg8ocIWz-B8cBo4L6nzZTcv0UD9juGZsoaXtdL59f2lt7ea3iA=s96-c'),
            ),
            SizedBox(height: 10),
            Text(
              'FORSLOG Oran',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'forslog@gmail.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                ),
                SizedBox(width: 5),
                Text(
                  '0 coins',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
