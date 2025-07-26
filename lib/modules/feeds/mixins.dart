String getAvatar(int avatar) {
  switch (avatar) {
    case 1:
      return 'assets/images/male_active.png';
    case 2:
      return 'assets/images/female_active.png';
    case 3:
      return 'assets/images/admin.png';
    default:
      return '';
  }
}
