Future<bool> checkLogIn({username, password}) async {
  await Future.delayed(Duration(seconds: 3));
  if (username == "mouaz" && password == "test") {
    return true;
  } else {
    return false;
  }
}
