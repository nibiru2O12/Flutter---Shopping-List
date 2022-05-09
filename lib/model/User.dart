class User {
  User(
      {this.gender = "",
      this.last_name = "",
      this.first_name = "",
      this.middle_name = "",
      this.address = "",
      this.contact = "",
      this.email = ""});

  String last_name;
  String first_name;
  String middle_name;
  String address;
  String contact;
  String email;
  String gender;

  User.fromUser(User user)
      : gender = user.gender,
        last_name = user.last_name,
        first_name = user.first_name,
        middle_name = user.middle_name,
        address = user.address,
        contact = user.contact,
        email = user.email;
}
