/* filter_contigs_by_virfinder_filtered_results (e.g. qvalue < threshold)
 * Zifan Zhu
 */

#include <iostream>
#include <fstream>
#include <string>
#include <unordered_map>


using namespace std;


int main (int argc, const char* const argv[]) {
  if (argc != 4) {
    cerr << "CORRECT USAGE: " << argv[0] << " <VIRFINDER_FILTERED_RESULTS> "
         << "<CONTIG_FASTA_FILE> <OUT_FILE>" << endl;
    return EXIT_FAILURE;
  }


  const string vf_name (argv[1]);
  const string contig_name (argv[2]);
  const string out_file (argv[3]);


  ifstream vf (vf_name.c_str());
  string line;
  unordered_map<string, int> name_hash;


  // create a hash table of virfinder filtered results
  if (vf.is_open()) {
    getline(vf, line);
    while (getline(vf, line)) {
      name_hash[line.substr(0, line.find_first_of(' '))] = 0;
    }
    vf.close();
  }
  else cout << "Unable to open file " << vf_name << endl;


  // process contig file
  ofstream contig_o (out_file.c_str());
  ifstream contig (contig_name.c_str());
  if (contig.is_open() && contig_o.is_open()) {
    while (getline(contig, line)) {
      if (name_hash.find(line.substr(1, line.find_first_of(' ') - 1))
          != name_hash.end()){// ' ' might be modified due to different files
        contig_o << line << '\n';
        getline(contig, line);
        contig_o << line << '\n';
      }
      else {
        getline(contig, line);
      }
    }
    contig.close();
    contig_o.close();
  }
  else if (contig.is_open()) {
    cout << "Unable to write file " << out_file << endl;
  }
  else cout << "Unable to open file " << contig_name << endl;


  return 0;
}
