#include <iostream>
#include <string>

int main() {
  const std::string kKey = "MOSBURGER";
  size_t key_i = 0;

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
      c = base + ((c - base) - (kKey[key_i] - 'A') + 26) % 26;
      key_i = (key_i + 1) % kKey.size();
    }
    std::cout << s << std::endl;
  }
  return 0;
}
