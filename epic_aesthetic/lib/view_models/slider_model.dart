class SliderModel{
  String imagePath;
  String title;
  String desc;

  SliderModel({
    this.imagePath,
    this.title,
    this.desc,
  });

  void setImageAssetPath(String imagePath){
    this.imagePath = imagePath;
  }

  void setTitle(String title) {
    this.title = title;
  }

  void setDesc(String desc){
    this.desc = desc;
  }

  String getImageAssetPath() => imagePath;
  String getTitle() => title;
  String getDesc() => desc;
}

List<SliderModel> getSlides(){
  var slides = new List<SliderModel>();

  var sliderModel1 = SliderModel();
  sliderModel1.setImageAssetPath("assets/onboarding_1.png");
  sliderModel1.setTitle("Upload your EPIC or AESTHETIC photos!");
  sliderModel1.setDesc("");
  slides.add(sliderModel1);

  var sliderModel2 = SliderModel();
  sliderModel2.setImageAssetPath("assets/onboarding_2.png");
  sliderModel2.setTitle("Rate others!");
  sliderModel2.setDesc("");
  slides.add(sliderModel2);

  var sliderModel3 = SliderModel();
  sliderModel3.setImageAssetPath("assets/onboarding_3.png");
  sliderModel3.setTitle("See the top of the month!");
  sliderModel3.setDesc("");
  slides.add(sliderModel3);

  return slides;
}