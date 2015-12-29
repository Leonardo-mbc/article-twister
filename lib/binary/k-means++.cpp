#include <iostream>
#include <fstream>
#include <math.h>
#include <vector>
#include <sstream>
#include <string>
#include <random>
using namespace std;

inline int toInt(std::string s) {int v; std::istringstream sin(s);sin>>v;return v;}
inline float toFloat(std::string s) {float v; std::istringstream sin(s);sin>>v;return v;}

random_device rnd;
mt19937 mt(rnd());

class Point {
public:
    int id;
    float x = 0.0, y = 0.0;
    int cluster = -1;
    int size = 0;
    bool used = false;

    Point(int id, float x, float y) {
        this->id = id;
        this->x = x;
        this->y = y;
    }
};

class Cluster {
public:
    int cluster = -1;
    float x = 0.0, y = 0.0;

    Cluster(int cluster, float x, float y) {
        this->cluster = cluster;
        this->x = x;
        this->y = y;
    }
};

class Prob {
public:
    int id;
    float prob = 0.0, accum = 0.0;

    Prob(int id, float prob, float accum) {
        this->id = id;
        this->prob = prob;
        this->accum = accum;
    }
};

int roulette(vector<Prob> *prob, vector<Point> *vec) {
    uniform_real_distribution<> rt(0.0, (prob->end() - 1)->accum);
    float p = rt(mt);

    int n = 0;
    while(prob->at(n).accum <= p) n++;

    if(vec->at(n).used) {
        n = roulette(prob, vec);
    } else {
        vec->at(n).used = true;
    }

    return n;
}

vector<string> split(string s, string c) {
  vector<string> ret;
  for(int i = 0, n; i <= s.length(); i=n+1) {
	n = s.find_first_of(c, i);
	if(n == string::npos) n = s.length();
	string tmp = s.substr(i, n-i);
	ret.push_back(tmp);
  }
  return ret;
}

int main(int argc,char *argv[]) {
    int loop = 100;
    int divide = toInt(argv[2]);
    vector<Point> vec;
    vector<Point> sum;
    vector<Cluster> cluster;

    ifstream fin(argv[1]);

    if(fin.is_open()) {
        string str;
        while(getline(fin, str)) {
            vector<string> strvec = split(str, ",");
            int id = toInt(strvec.at(0));
            float x = toFloat(strvec.at(1));
            float y = toFloat(strvec.at(2));

            Point *v = new Point(id, x, y);
            vec.push_back(*v);
        }
    } else {
        cout << "File: open faild" << endl;
    }
    fin.close();

    uniform_int_distribution<> rand(0, vec.size() - 1);
    int selected = rand(mt);

    for(int c = 0; c < divide; c++) {
        vector<Prob> prob;
        float acm = 0.0;

        Cluster *cls = new Cluster(c, vec.at(selected).x, vec.at(selected).y);
        cluster.push_back(*cls);

        for(vector<Point>::iterator it = vec.begin(); it != vec.end(); ++it) {
            double dist = sqrt(pow((double)(cluster.at(0).x - it->x), 2.0) + pow((double)(cluster.at(0).y - it->y), 2.0));
            acm += dist;
            Prob *prb = new Prob(it->id, dist, acm);
            prob.push_back(*prb);
        }

        for(vector<Prob>::iterator it = prob.begin() + 1; it != prob.end(); ++it) {
            it->prob = it->prob / (prob.end() - 1)->accum;
        }

        selected = roulette(&prob, &vec);
    }

    for(int c = 0; c < divide; c++) {
        Point *g = new Point(c, 0, 0);
        sum.push_back(*g);
    }

    for(int n = 0; n < loop; n++) {
        for(int i = 0; i < vec.size(); i++) {
            double slv = HUGE_VAL;

            for(int c = 0; c < divide; c++) {
                double tslv = sqrt(pow((double)(cluster.at(c).x - vec.at(i).x), 2.0) + pow((double)(cluster.at(c).y - vec.at(i).y), 2.0));

                if(tslv < slv) {
                    vec.at(i).cluster = c;
                    slv = tslv;
                }
            }
        }

        for(vector<Point>::iterator it = sum.begin(); it != sum.end(); ++it) {
            it->x = 0.0;
            it->y = 0.0;
            it->size = 0;
        }

        for(int i = 0; i < vec.size(); i++) {
            sum.at(vec.at(i).cluster).x += vec.at(i).x;
            sum.at(vec.at(i).cluster).y += vec.at(i).y;
            sum.at(vec.at(i).cluster).size++;
        }

        for(vector<Point>::iterator it = sum.begin(); it != sum.end(); ++it) {
            cluster.at(it->id).x = it->x / it->size;
            cluster.at(it->id).y = it->y / it->size;
        }

    }

    for(vector<Cluster>::iterator it = cluster.begin(); it != cluster.end(); ++it)
        cout << it->cluster << "," << it->x << "," << it->y << endl;

    cout << '$' << endl;

    for(vector<Point>::iterator it = vec.begin(); it != vec.end(); ++it) {
        cout << it->id << "," << it->cluster << endl;
        cerr << it->id << "," << it->cluster << endl;
    }

    return 0;
}
