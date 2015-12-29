#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <mecab.h>
#include <algorithm>
using namespace std;

vector<string> split(string s, string c) {
        vector<string> ret;
        for(int i=0, n; i <= s.length(); i=n+1) {
                n = s.find_first_of(c, i);
                if(n == string::npos) n = s.length();
                string tmp = s.substr(i, n-i);
                ret.push_back(tmp);
        }
        return ret;
}

typedef map<string, int>::const_iterator map_freq_it;
typedef std::vector<map_freq_it>::const_iterator vec_stu_citer_t;

bool compare( const map_freq_it& a, const map_freq_it& b ) {
        return ( a->second > b->second );
}

int main(int argc, char **argv)
{
        ifstream fin(argv[1]);
        string str;
        char c;
        while(fin.get(c)) {
                str.push_back(c);
        }

        cout << str.c_str() << endl;
        MeCab::Tagger *tagger = MeCab::createTagger("");
        const MeCab::Node *node = tagger->parseToNode(str.c_str());
        map<string, int> freq;
        map<string, int>::iterator it;

        for(node=node->next; node->next; node=node->next) {
                vector<string> strvec = split(node->feature, ",");
                cout << strvec[6] << node->feature << endl;
                if(strvec[0] == "名詞") {
                        string noun = strvec[6];
                        it = freq.find(noun);
                        if (it != freq.end()) {
                                it->second += 1;
                        } else {
                                freq.insert(pair<string, int>(noun, 1));
                        }
                }
        }

        vector<map_freq_it> sorted;
        for(map_freq_it mfi = freq.begin(); mfi != freq.end(); ++mfi)
                sorted.push_back(mfi);

        sort(sorted.begin(), sorted.end(), compare);

        for(vec_stu_citer_t it = sorted.begin(); it != sorted.end(); ++it) {
                cout << (*it)->first << ",";
                cout << (*it)->second <<endl;
        }

        delete tagger;
        return 0;
}
