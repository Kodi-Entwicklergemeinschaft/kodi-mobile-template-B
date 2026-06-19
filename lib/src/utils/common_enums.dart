enum PostStatusType{
  approved,
  pending,
  feedback;

  int get value {
    if (this == PostStatusType.approved) return 1;
    if (this == PostStatusType.pending) return 2;
    return 3;
  }


}