import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../states.dart';

class GoogleAuthStatus extends StatelessWidget {
  const GoogleAuthStatus({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Consumer<AuthenticatedUser>(
        builder: (context, googleAuth, child) => Card(
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FutureBuilder(
                future: googleAuth.isSignedIn,
                builder: (context, snapshot) => (snapshot.hasData)
                    ? (snapshot.data as bool)
                        ? Column(children: [
                            FutureBuilder(
                              future: googleAuth.user,
                              builder: (context, user) => RichText(
                                text: TextSpan(
                                  text: "Logged in as ",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  children: [
                                    (user.hasData && user.data != null)
                                        ? TextSpan(
                                            text: (user.data
                                                    as GoogleSignInAccount)
                                                .displayName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))
                                        : const TextSpan(
                                            text: "Unknown",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  await googleAuth.signOut();
                                },
                                child: const Text("Sign out"))
                          ])
                        : Column(children: [
                            const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  await googleAuth.signIn();
                                },
                                child: const Text("Sign in")),
                            (googleAuth.hasError)
                                ? Text(
                                    googleAuth.error,
                                    style: const TextStyle(color: Colors.red),
                                  )
                                : const SizedBox()
                          ])
                    : const Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
            )),
      ),
    );
  }
}
