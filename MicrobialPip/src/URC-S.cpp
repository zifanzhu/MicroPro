/* URC: get_unmapped_reads_from_centrifuge_output
 */

#include <iostream>
#include <fstream>
#include <string>
#include <unordered_map>


using namespace std;


int main (int argc, const char* const argv[]) {
  if (argc != 4) {
    cerr << "CORRECT USAGE: " << argv[0] << " <CENTRIFUGE_OUTPUT> "
         << "<FASTQ> <OUT_FILE>" << endl;
    return EXIT_FAILURE;
  }


  const string ctf_name (argv[1]);
  const string fq1_name (argv[2]);
  const string out_file_1 (argv[3]);

  ifstream ctf (ctf_name.c_str());
  string line;
  unordered_map<string, int> name_hash;


  // create a hash table of mapped reads names
  if (ctf.is_open()) {
    getline(ctf, line);
    while (getline(ctf, line)) {
      name_hash[line.substr(0, line.find_first_of('\t'))] = 0;
    }
    ctf.close();
  }
  else cout << "Unable to open file " << ctf_name << endl;


  // process first fastq file
  ofstream fq1_o (out_file_1.c_str());
  ifstream fq1 (fq1_name.c_str());
  if (fq1.is_open() && fq1_o.is_open()) {
    while (getline(fq1, line)) {
      if (name_hash.find(line.substr(1, line.find_first_of(' ') - 1))
          == name_hash.end() && name_hash.find(line.substr(1,
          line.find_first_of('/') - 1)) == name_hash.end()) {
          // ' ' or '/' might be modified due to different files
        fq1_o << line << '\n';
        getline(fq1, line);
        fq1_o << line << '\n';
        getline(fq1, line);
        fq1_o << line << '\n';
        getline(fq1, line);
        fq1_o << line << '\n';
      }
      else {
        getline(fq1, line);
        getline(fq1, line);
        getline(fq1, line);
      }
    }
    fq1.close();
    fq1_o.close();
  }
  else if (fq1.is_open()) {
    cout << "Unable to write file " << out_file_1 << endl;
  }
  else cout << "Unable to open file " << fq1_name << endl;
}
