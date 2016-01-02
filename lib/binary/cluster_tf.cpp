#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include <sstream>
#include <algorithm>
#include <cmath>
using namespace std;

inline int toInt(std::string s) {int v; std::istringstream sin(s);sin>>v;return v;}
typedef map<string, int>::const_iterator map_freq_it;
typedef map<string, double>::const_iterator map_freq_db;

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

bool compare(const map_freq_db& a, const map_freq_db& b) {
    return (a->second > b->second);
}

class Frequency {
public:
    string news_dir = "";
    int cluster = -1;
    map<string, int> words;
    map<string, double> words_tfidf;
    int total_words = 0;

    Frequency(int cluster, string news_dir) {
        this->cluster = cluster;
        this->news_dir = news_dir;
    }

    void count(int news_id) {
        stringstream filename;
        filename << this->news_dir << news_id << ".txt";
        ifstream fin(filename.str());

        if(fin.is_open()) {
            string str;
            while(getline(fin, str)) {
                vector<string> strvec = split(str, ",");
                string word = strvec.at(0);
                int quant = toInt(strvec.at(1));
                this->add(word, quant);
                this->total_words += quant;
            }
        }

        fin.close();
    }

    void add(string word, int quant) {
        map<string, int>::iterator it;

        it = this->words.find(word);
        if (it != this->words.end()) {
            it->second += quant;
        } else {
            this->words.insert(pair<string, int>(word, quant));
        }
    }

    void load(string filename) {
        stringstream filepath;
        filepath << this->news_dir << filename;
        ifstream fin(filepath.str());

        if(fin.is_open()) {
            string str;
            while(getline(fin, str)) {
                vector<string> strvec = split(str, ",");
                string word = strvec.at(0);
                int quant = toInt(strvec.at(1));
                this->add(word, quant);
            }
        }

        fin.close();
    }

    void tfidf(map<string, int> corpus, int Dn) {
        for(map_freq_it w = this->words.begin(); w != this->words.end(); ++w) {
            map<string, int>::iterator search;
            search = corpus.find(w->first);

            int df = 0;
            if (search != corpus.end()) df = search->second;

            double tv = (w->second / (double)this->total_words) * log(Dn / (double)df);
            this->words_tfidf.insert(pair<string, double>(w->first, tv));
        }
    }
};

class Cluster {
public:
    int id = -1;
    int cluster = -1;

    Cluster(int id, int cluster) {
        this->id = id;
        this->cluster = cluster;
    }
};

int main(int argc, char **argv) {
    int cluster_quant = 0;
    int corpus_num = 0;
    string news_dir = argv[2];
    int output = toInt(argv[3]);

    vector<Cluster> clusters;
    vector<Frequency> frequencies;

    Frequency *corpus_df = new Frequency(0, news_dir);
    corpus_df->load("../corpus_df/corpus_df.txt");

    ifstream fin(argv[1]);
    if(fin.is_open()) {
        string str;
        while(getline(fin, str)) {
            vector<string> strvec = split(str, ",");
            int cluster = toInt(strvec.at(1));
            int id = toInt(strvec.at(0));

            if(cluster_quant < cluster) cluster_quant = cluster;

            Cluster *c = new Cluster(id, cluster);
            clusters.push_back(*c);
        }
    } else {
        cout << "File: open faild" << endl;
        return 0;
    }
    fin.close();

    for(int c = 0; c <= cluster_quant; c++) {
        Frequency *f = new Frequency(c, news_dir);
        frequencies.push_back(*f);
    }

    for(vector<Cluster>::iterator it = clusters.begin(); it != clusters.end(); ++it) {
        frequencies.at(it->cluster).count(it->id);
    }

    for(vector<Frequency>::iterator it = frequencies.begin(); it != frequencies.end(); ++it) {
        it->tfidf(corpus_df->words, clusters.size());

        vector<map_freq_db> sorted;
        sorted.clear();
        for(map_freq_db mfi = it->words_tfidf.begin(); mfi != it->words_tfidf.end(); ++mfi)
            sorted.push_back(mfi);

        sort(sorted.begin(), sorted.end(), compare);

        for(int o = 0; o < output && o < sorted.size(); o++) {
            cout << sorted.at(o)->first << endl;
        }
        cout << "$" << endl;
    }

    return 0;
}
