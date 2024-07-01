abstract class Answer<T> {
  final String code;
  Answer(this.code);

  T process(String msg);
}