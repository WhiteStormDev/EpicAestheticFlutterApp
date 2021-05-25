class ImageModel {
  String id;
  String userId;
  String imageUrl;
  Map epicLikes;
  Map aestheticLikes;
  DateTime dateTime;

  ImageModel.fromParameters(String uid, String imageUrl, String userId,
      Map epicLikes, Map aestheticLikes, DateTime dateTime) {
    this.id = uid;
    this.imageUrl = imageUrl;
    this.userId = userId;
    this.epicLikes = epicLikes;
    this.dateTime = dateTime;
  }

  ImageModel.fromJson(String uid, Map<String, dynamic> values) {
    this.id = uid;
    this.userId = values['userId'];
    this.imageUrl = values['imageUrl'];
    this.epicLikes = values['epicLikes'];
    this.aestheticLikes = values['aestheticLikes'];
    this.dateTime = values['dateTime'];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "imageUrl": imageUrl,
      "userId": userId,
      "epicLikes": epicLikes,
      "aestheticLikes": aestheticLikes,
      "dateTime": dateTime
    };
  }
}