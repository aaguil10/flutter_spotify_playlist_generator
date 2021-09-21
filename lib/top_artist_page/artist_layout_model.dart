enum ListItemType { topSection, header, item }
enum Category { top, middle, bottom, black, none }

class ArtistLayoutModel {
  ListItemType listItem;
  String id;
  String name;
  String sub;
  Category category;

  ArtistLayoutModel(this.listItem,
      [this.id, this.name, this.sub, this.category = Category.none]);
}
