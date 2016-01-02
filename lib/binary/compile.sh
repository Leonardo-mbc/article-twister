g++ -fopenmp -std=c++11 `mecab-config --cflags` `mecab-config --libs` count.cpp -o ../../app/bin/count
g++ -fopenmp -std=c++11 similar.cpp -o ../../app/bin/similar
g++ -std=c++11 cluster_tf.cpp -o ../../app/bin/cluster_tf
g++ -std=c++11 k-means++.cpp -o ../../app/bin/k-means++
g++ -std=c++11 corpus_df.cpp -o ../../app/bin/corpus_df
