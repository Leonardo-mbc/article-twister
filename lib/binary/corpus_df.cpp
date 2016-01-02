#include <sys/types.h>
#include <dirent.h>
#include <iostream>
#include <cstring>
#include <fstream>
#include <sstream>
#include <map>
#include <vector>
using namespace std;

inline int toInt(std::string s) {int v; std::istringstream sin(s);sin>>v;return v;}

vector<string> split(string s, string c) {
    vector<string> ret;
    for(int i = 0, n; i <= s.length(); i = n + 1) {
        n = s.find_first_of(c, i);
        if(n == string::npos) n = s.length();
        string tmp = s.substr(i, n - i);
        ret.push_back(tmp);
    }
    return ret;
}

class Frequency {
public:
    string news_dir = "";
    map<string, int> words;

    Frequency(string news_dir) {
        this->news_dir = news_dir;
    }

    void add(int news_id, int quant) {
        stringstream filename;
        filename << this->news_dir << news_id << ".txt";
        ifstream fin(filename.str());

        if(fin.is_open()) {
            string str;
            while(getline(fin, str)) {
                vector<string> strvec = split(str, ",");
                string word = strvec.at(0);
                map<string, int>::iterator it;

                it = this->words.find(word);
                if (it != this->words.end()) {
                    it->second += quant;
                } else {
                    this->words.insert(pair<string, int>(word, quant));
                }
            }
        }

        fin.close();
    }
};

int main(int argc, char *argv[]) {
    struct dirent *de = NULL;
    DIR *d = NULL;
    string news_dir = argv[1];

    d = opendir(argv[1]);
    if(d == NULL) return 0;

    Frequency *frequency = new Frequency(news_dir);

    while(de = readdir(d)) {
        if (strcmp(de->d_name, ".") && strcmp(de->d_name, "..") && strcmp(de->d_name, ".DS_Store") && strcmp(de->d_name, "corpus_df.txt")) {
            frequency->add(toInt(de->d_name), 1);
        }
    }

    for(map<string, int>::iterator it = frequency->words.begin(); it != frequency->words.end(); ++it) {
        cout << it->first << "," << it->second << endl;
    }

    closedir(d);

    return(0);
}
