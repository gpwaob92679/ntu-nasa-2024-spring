#include <iostream>

int main() {
  char kMap[27] = "MBQVXIERKDPHABLZTFSGWUCNYO";
  std::string s;
  while (std::getline(std::cin, s)) {
    for (char& c : s) {
      if (!isalpha(c)) {
        continue;
      }
      char base;
      if (islower(c)) {
        base = 'a';
      } else {
        base = 'A';
      }
      c = base + kMap[c - base] - 'A';
    }
    std::cout << s << std::endl;
  }
  return 0;
}
