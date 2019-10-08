class News{
  final String newsId;
  final String newsAdd;
  final String newsDateAdd;
  final String newsTopic;
  final String newsDetail;
  final String newsImages;
  final String newsStatus;
  final String newsNote;
  final String newsMode;

  News({
    this.newsId,
    this.newsAdd,
    this.newsDateAdd,
    this.newsTopic,
    this.newsDetail,
    this.newsImages,
    this.newsStatus,
    this.newsNote,
    this.newsMode
  });

  factory News.fromJson(Map<String, dynamic> json){
    return new News(
      newsId: json['new_id'],
      newsAdd: json['new_add'],
      newsDateAdd: json['new_dateAdd'],
      newsTopic: json['new_topic'],
      newsDetail: json['new_detial'],
      newsImages: json['new_images'],
      newsStatus: json['new_status'],
      newsNote: json['new_note'],
      newsMode: json['new_mode'],
    );
  }
}