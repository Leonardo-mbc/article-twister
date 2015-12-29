#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <vector>
#include <sstream>
#include <math.h>
using namespace std;

inline int toInt(std::string s) {int v; std::istringstream sin(s);sin>>v;return v;}
typedef map<string, int>::const_iterator words_it;

vector<string> split(string s, string c) {
  vector<string> ret;
  for(int i=0, n; i <= s.length(); i=n+1) {
	n = s.find_first_of( c, i );
	if(n == string::npos) n = s.length();
	string tmp = s.substr(i, n-i);
	ret.push_back(tmp);
  }
  return ret;
}

int main(int argc, char **argv) {
    map<string, int> words1, words2;
    vector<string> strvec1, strvec2;

    string str1, str2;
    int i1, i2, norm1 = 0, norm2 = 0;
    float value1, value2;

    ifstream fin1(argv[1]);
    ifstream fin2(argv[2]);

    #pragma omp parallel
    #pragma omp sections
    {
        #pragma omp section
        {
            if(fin1.is_open()) {
                while(getline(fin1, str1)) {
                    strvec1 = split(str1, ",");
                    i1 = toInt(strvec1.at(1));
                    norm1 += i1 * i1;
                    words1.insert(pair<string, int>(strvec1.at(0), i1));
                }
            } else {
                cout << "File1: open faild" << endl;
            }
        }

        #pragma omp section
        {
            if(fin2.is_open()) {
                while(getline(fin2, str2)) {
                    strvec2 = split(str2, ",");
                    i2 = toInt(strvec2.at(1));
                    norm2 += i2 * i2;
                    words2.insert(pair<string, int>(strvec2.at(0), i2));
                }
            } else {
                cout << "File2: open faild" << endl;
            }
        }
    }

    float upper_sum = 0.0;
    for(words_it it = words1.begin(); it != words1.end(); ++it) {
        value1 = (float)it->second;
        auto search = words2.find(it->first);

        if(search == words2.end()) value2 = 0.0;
            else value2 = (float)search->second;

        upper_sum += value1 * value2;
    }

    float similarity = upper_sum / (sqrt(norm1) * sqrt(norm2));
    cout << similarity << endl;

    return 0;
}
