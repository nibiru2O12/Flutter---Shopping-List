import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hello_world/model/User.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(label: "Save", icon: Icon(Icons.save)),
          BottomNavigationBarItem(label: "Cancel", icon: Icon(Icons.cancel)),
        ],
      ),
      appBar: AppBar(
        title: const Text("User Settings"),
      ),
      body: UserInputs(
        user: User(
            last_name: "last_name",
            first_name: "first_name",
            gender: "MALE",
            address: "address",
            contact: "contact",
            email: "email"),
      ),
    );
  }
}

class UserInputs extends StatefulWidget {
  const UserInputs({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<UserInputs> createState() => _UserInputsState();
}

class _UserInputsState extends State<UserInputs> {
  final _formKey = GlobalKey<FormState>();

  late User _user;
  void onSubmit(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Saving"),
            content: Column(
              children: [
                Text("NewLast Name: " + _user.last_name),
                Text("Old Last Name: " + widget.user.last_name),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    // _user = User.fromUser(widget.user);
    _user = new User();
  }

  dynamic isRequired({dynamic value, String message = "Value is required"}) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

  // InputDecoration inputDecor = InputDecoration(
  //     fillColor: Colors.blue.shade100,
  //     filled: true,
  //     prefixIcon: Icon(Icons.person),
  //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)));

  InputDecoration inputDecor = InputDecoration(
    fillColor: Colors.blue.shade100,
    filled: false,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: WithSpacer(
              spacer: EdgeInsets.only(bottom: 10),
              children: [
                TextFormField(
                    onChanged: ((value) => _user.last_name = value),
                    initialValue: _user.last_name,
                    validator: (e) => isRequired(value: e),
                    decoration: inputDecor.copyWith(
                        prefixIcon: Icon(Icons.person),
                        label: const Text("Last Name"),
                        hintText: "Last Name")),
                TextFormField(
                    onChanged: ((value) => _user.last_name = value),
                    initialValue: _user.last_name,
                    validator: (e) => isRequired(value: e),
                    decoration: inputDecor.copyWith(
                        prefixIcon: Icon(Icons.person),
                        label: const Text("First Name"),
                        hintText: "First Name")),
                TextFormField(
                    onChanged: ((value) => _user.last_name = value),
                    initialValue: _user.last_name,
                    validator: (e) => isRequired(value: e),
                    decoration: inputDecor.copyWith(
                        prefixIcon: Icon(Icons.person),
                        label: const Text("Middle Name"),
                        hintText: "Middle Name")),
                DropdownButtonFormField(
                    value: _user.gender,
                    decoration: inputDecor.copyWith(
                        label: Text("Gender"),
                        hintText: "Gender",
                        prefixIcon: Icon(Icons.transgender)),
                    hint: const Text("Gender"),
                    items: const [
                      DropdownMenuItem(value: "", child: Text("")),
                      DropdownMenuItem(value: "MALE", child: Text("MALE")),
                      DropdownMenuItem(value: "FEMALE", child: Text("FEMALE")),
                    ],
                    onChanged: (String? value) => _user.gender = value!),
                TextFormField(
                  initialValue: _user.address,
                  validator: (e) =>
                      isRequired(value: e, message: "Enter your address"),
                  maxLines: 5,
                  decoration: inputDecor.copyWith(
                      label: Text("Address"),
                      hintText: "Address",
                      prefixIcon: Icon(Icons.location_city)),
                  onChanged: (e) => _user.address = e,
                ),
                TextFormField(
                  initialValue: _user.contact,
                  validator: (e) => isRequired(
                      value: e,
                      message: "Please provide a valid contact number"),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.contact_phone),
                    label: Text("Contact Number"),
                  ),
                ),
                TextFormField(
                  initialValue: _user.email,
                  validator: (e) => isRequired(
                      value: e,
                      message: "Please provide a valid email address"),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    label: Text("Email"),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() == false) {
                        return;
                      }
                      onSubmit(context);
                    },
                    child: Text("Submit"))
              ],
            ),
          )),
    );
  }
}

class WithSpacer extends StatelessWidget {
  const WithSpacer({Key? key, required this.children, required this.spacer})
      : super(key: key);

  final List<Widget> children;
  final EdgeInsets spacer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.map((Widget e) {
        return Padding(
          padding: spacer,
          child: e,
        );
      }).toList(),
    );
  }
}

class GroupedTextField extends StatelessWidget {
  const GroupedTextField({
    Key? key,
    required this.textfields,
  }) : super(key: key);

  final List<TextFormField> textfields;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: textfields.map((TextFormField e) {
        return e;
      }).toList(),
    );
  }
}
