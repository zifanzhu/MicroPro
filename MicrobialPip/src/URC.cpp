/* get_unmapped_reads_from_centrifuge_output
 * designed for centrifuge version >= 1.0.3
 * Zifan Zhu
 */

#include <iostream>
#include <fstream>
#include <string>
#include <unordered_map>


using namespace std;


int main (int argc, const char* const argv[]) {
  if (argc != 6) {
    cerr << "CORRECT USAGE: " << argv[0] << " <CENTRIFUGE_OUTPUT> "
         << "<FASTQ_PAIR_1> <FASTQ_PAIR_2> <OUT_FILE_1> <OUT_FILE_2>" << endl;
    return EXIT_FAILURE;
  }


  const string ctf_name (argv[1]);
  const string fq1_name (argv[2]);
  const string fq2_name (argv[3]);
  const string out_file_1 (argv[4]);
  const string out_file_2 (argv[5]);

  ifstream ctf (ctf_name.c_str());
  string line;
  size_t f;
  unordered_map<string, int> name_hash;


  // create a hash table of mapped reads names
  if (ctf.is_open()) {
    getline(ctf, line);
    while (getline(ctf, line)) {
      f = line.find_first_of('\t') + 1;
      if (line.substr(f, line.find_first_of('\t', f) - f) != "unclassified"){
      	name_hash[line.substr(0, f - 1)] = 0;
      }
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


  // process second fastq file
  ofstream fq2_o (out_file_2.c_str());
  ifstream fq2 (fq2_name.c_str());
  if (fq2.is_open() && fq2_o.is_open()) {
    while (getline(fq2, line)) {
      if (name_hash.find(line.substr(1, line.find_first_of(' ') - 1))
          == name_hash.end() && name_hash.find(line.substr(1,
          line.find_first_of('/') - 1)) == name_hash.end()) {
          // ' ' or '/' might be modified due to different files
        fq2_o << line << '\n';
        getline(fq2, line);
        fq2_o << line << '\n';
        getline(fq2, line);
        fq2_o << line << '\n';
        getline(fq2, line);
        fq2_o << line << '\n';
      }
      else {
        getline(fq2, line);
        getline(fq2, line);
        getline(fq2, line);
      }
    }
    fq2.close();
    fq2_o.close();
  }
  else if (fq2.is_open()) {
    cout << "Unable to write file " << out_file_2 << endl;
  }
  else cout << "Unable to open file " << fq2_name << endl;


  return 0;
}
