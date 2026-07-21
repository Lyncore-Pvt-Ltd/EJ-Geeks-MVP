import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SvgPicture.asset(
                  //   'assets/Emblem_of_Sri_Lanka.svg',
                  //   height: 80,
                  //   width: 80,
                  //   placeholderBuilder: (context) => const SizedBox(
                  //     height: 80,
                  //     width: 80,
                  //     child: Center(
                  //       child: CircularProgressIndicator(strokeWidth: 2),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  const Text('E&J Geek Invoice'),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    // Handle Home tap
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    //Navigator.push(context, SettingScreen.route());
                  },
                ),
                // ExpansionTile(
                //   leading: const Icon(Icons.settings),
                //   title: const Text('Offices'),
                //   shape: const Border(),
                //   children: [
                //     ListTile(
                //       contentPadding: const EdgeInsets.only(left: 25),
                //       leading: const Icon(Icons.personal_injury_outlined),
                //       title: const Text('Ministry of Education Office'),
                //       onTap: () {
                //         // Handle General settings tap
                //       },
                //     ),
                //     ListTile(
                //       contentPadding: const EdgeInsets.only(left: 25),
                //       leading: const Icon(Icons.privacy_tip),
                //       title: const Text('Provincial Ministry of Education'),
                //       onTap: () {
                //         // Handle Privacy settings tap
                //       },
                //     ),
                //     ListTile(
                //       contentPadding: const EdgeInsets.only(left: 25),
                //       leading: const Icon(Icons.notifications),
                //       title: const Text('Provincial Department of Education'),
                //       onTap: () {
                //         // Handle Notifications settings tap
                //       },
                //     ),
                //     ListTile(
                //       contentPadding: const EdgeInsets.only(left: 25),
                //       leading: const Icon(Icons.notifications),
                //       title: const Text('Zonal Education Office'),
                //       onTap: () {
                //         // Handle Notifications settings tap
                //       },
                //     ),
                //     ListTile(
                //       contentPadding: const EdgeInsets.only(left: 25),
                //       leading: const Icon(Icons.notifications),
                //       title: const Text('Divisional Education Office'),
                //       onTap: () {
                //         // Handle Notifications settings tap
                //       },
                //     ),
                //   ],
                // ),
                // ExpansionTile(
                //   leading: const Icon(Icons.contact_mail),
                //   title: const Text('Employees'),
                //   shape: const Border(),
                //   children: [
                //     ListTile(
                //       contentPadding: const EdgeInsets.only(left: 72),
                //       title: const Text('Teachers'),
                //       onTap: () {
                //         // Handle Email tap
                //       },
                //     ),
                //     ListTile(
                //       contentPadding: const EdgeInsets.only(left: 72),
                //       title: const Text('Principal'),
                //       onTap: () {
                //         // Handle Phone tap
                //       },
                //     ),
                //   ],
                // ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {},
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '© All Rights Reserved. Lyncore Pvt. Ltd 2026',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
