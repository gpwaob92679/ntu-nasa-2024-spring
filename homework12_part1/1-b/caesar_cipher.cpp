#include <iostream>
#include <string>

int main() {
  std::string s;
  std::cin >> s;
  for (int i = 0; i < 26; ++i) {
    std::cout << "rotate " << i << ": " << s << std::endl;
    for (char& c : s) {
      if (!isalpha(c)) {
        continue;
      }
      if (c == 'z') {
        c = 'a';
      } else {
        ++c;
      }
    }
  }
  return 0;
}
