// ESE 507 Project 3 Handout Code
// Fall 2020
// You may not redistribute this code

// Getting started:
// The main() function contains the code to read the parameters. 
// For Parts 1 and 2, your code should be in the genFCLayer() function. Please
// also look at this function to see an example for how to create the ROMs.
//
// For Part 3, your code should be in the genNetwork() function.



#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdlib>
#include <cstring>
#include <assert.h>
#include <math.h>
using namespace std;

void printUsage();
void genFCLayer(int M, int N, int T, int R, int P, vector<int>& constvector, string modName, ofstream &os);
void genNetwork(int N, int M1, int M2, int M3, int T, int R, int B, vector<int>& constVector, string modName, ofstream &os);
void readConstants(ifstream &constStream, vector<int>& constvector);
void genROM(vector<int>& constVector, int bits, string modName, ofstream &os);

int main(int argc, char* argv[]) {

   // If the user runs the program without enough parameters, print a helpful message
   // and quit.
   if (argc < 7) {
      printUsage();
      return 1;
   }

   int mode = atoi(argv[1]);

   ifstream const_file;
   ofstream os;
   vector<int> constVector;

   //----------------------------------------------------------------------
   // Look here for Part 1 and 2
   if (((mode == 1) && (argc == 7)) || ((mode == 2) && (argc == 8))) {

      // Mode 1/2: Generate one layer with given dimensions and one testbench

      // --------------- read parameters, etc. ---------------
      int M = atoi(argv[2]);
      int N = atoi(argv[3]);
      int T = atoi(argv[4]);
      int R = atoi(argv[5]);

      int P;

      if (mode == 1) {
         P=1;
         const_file.open(argv[6]);         
      }
      else {
         P = atoi(argv[6]);
         const_file.open(argv[7]);
      }

      if (const_file.is_open() != true) {
         cout << "ERROR reading constant file " << argv[6] << endl;
         return 1;
      }

      // Read the constants out of the provided file and place them in the constVector vector
      readConstants(const_file, constVector);

      string out_file = "fc_" + to_string(M) + "_" + to_string(N) + "_" + to_string(T) + "_" + to_string(R) + "_" + to_string(P) + ".sv";

      os.open(out_file);
      if (os.is_open() != true) {
         cout << "ERROR opening " << out_file << " for write." << endl;
         return 1;
      }
      // -------------------------------------------------------------

      // call the genFCLayer function you will write to generate this layer
      string modName = "fc_" + to_string(M) + "_" + to_string(N) + "_" + to_string(T) + "_" + to_string(R) + "_" + to_string(P);
      genFCLayer(M, N, T, R, P, constVector, modName, os); 

   }
   //--------------------------------------------------------------------


   // ----------------------------------------------------------------
   // Look here for Part 3
   else if ((mode == 3) && (argc == 10)) {
      // Mode 3: Generate three layers interconnected

      // --------------- read parameters, etc. ---------------
      int N  = atoi(argv[2]);
      int M1 = atoi(argv[3]);
      int M2 = atoi(argv[4]);
      int M3 = atoi(argv[5]);
      int T  = atoi(argv[6]);
      int R  = atoi(argv[7]);
      int B  = atoi(argv[8]);

      const_file.open(argv[9]);
      if (const_file.is_open() != true) {
         cout << "ERROR reading constant file " << argv[8] << endl;
         return 1;
      }
      readConstants(const_file, constVector);

      string out_file = "net_" + to_string(N) + "_" + to_string(M1) + "_" + to_string(M2) + "_" + to_string(M3) + "_" + to_string(T) + "_" + to_string(R) + "_" + to_string(B)+ ".sv";


      os.open(out_file);
      if (os.is_open() != true) {
         cout << "ERROR opening " << out_file << " for write." << endl;
         return 1;
      }
      // -------------------------------------------------------------

      string mod_name = "net_" + to_string(N) + "_" + to_string(M1) + "_" + to_string(M2) + "_" + to_string(M3) + "_" + to_string(T) + "_" + to_string(R) + "_" + to_string(B);

      // generate the design
      genNetwork(N, M1, M2, M3, T, R, B, constVector, mod_name, os);

   }
   //-------------------------------------------------------

   else {
      printUsage();
      return 1;
   }

   // close the output stream
   os.close();

}

// Read values from the constant file into the vector
void readConstants(ifstream &constStream, vector<int>& constvector) {
   string constLineString;
   while(getline(constStream, constLineString)) {
      int val = atoi(constLineString.c_str());
      constvector.push_back(val);
   }
}

// Generate a ROM based on values constVector.
// Values should each be "bits" number of bits.
void genROM(vector<int>& constVector, int bits, string modName, int P,  ofstream &os) {

      int numWords = constVector.size();
      int addrBits = ceil(log2(numWords));

      os << "module " << modName << "(clk, ";  //addr, z);" << endl;

      for(int i = 0; i < P; i++)
      {
         os << "addr" << i << ", ";
      }
      for(int i = 0; i < P; i++)
      {
         if(i != P-1)
         {
            os << "z" << i << ", ";
         }
         else os << "z" << i << ");" << endl;
      }

      os << "\tinput clk;" << endl;
      for(int i = 0; i < P; i++)
      {
         os << "\tinput [" << addrBits-1 << ":0] addr" << i << ";" << endl;
      }
      for(int i = 0; i < P; i++)
      {
         os << "\toutput logic signed [" << bits-1 << ":0] z" << i << ";" << endl;
      }
      os << "\talways_ff @(posedge clk) begin" << endl;
      
      for(int j = 0; j < P; j++)
      {
         os << "\t\tcase(addr" << j << ")" << endl;
         int i=0;
         for (vector<int>::iterator it = constVector.begin(); it < constVector.end(); it++, i++) {
            if (*it < 0)
               os << "\t\t" << i << ": z" << j << " <= -" << bits << "'d" << abs(*it) << ";" << endl;
            else
               os << "\t\t" << i << ": z" << j << " <= "  << bits << "'d" << *it      << ";" << endl;
         }
         os <<  "\t\tendcase" << endl;
      }
      os <<"\tend" << endl << "endmodule" << endl << endl;
}

//generate a mux
void genMux(string modName, int P, int T, ofstream &os)
{
   int selAddrBits = ceil(log2(P));
   //printf("selAddrBits = %d", selAddrBits);
   os << "module " << modName << "(";
   for(int i = 0; i < P; i++)
   {
      os << "parallel_out" << i << ", ";
   }
   os << "sel, f);" << endl;

   os << "\tparameter T = " << T << ";" << endl;
   os << "\tparameter P = " << P << ";" << endl << endl;

   os << "\toutput signed [T-1 : 0] f;" << endl;

   os << "\tinput logic unsigned [" << selAddrBits - 1 << " : 0] sel;" << endl;
   for(int i = 0; i < P; i++)
   {
      os << "\tinput signed [T-1 : 0] parallel_out" << i << ";" << endl;
   }

   os << "\tlogic unsigned [P*T-1 : 0] array;" << endl;
   os << "\tassign  array = {";
   for(int i = 0; i < P; i++)
   {
      if(i  != P-1)
      {
         os << "parallel_out" << i  << "[" << T-1 << " : 0], ";
      }
      else os << "parallel_out" << i  << "[" << T-1 << ": 0]};"<< endl << endl;
   }

   //os << "\tassign f = array[(sel+1)*T-1 : sel*T];" << endl << endl;
   os << "\tassign f = ";
   for(int i = 0; i < P; i++)
   {
      if(i != P-1)
      {
         if(i > 0) os << "\t\t\t";
         os << "(sel == " << i << ") ? parallel_out" << i << " : " << endl;
      }
      else os << "\t\t\t(sel == " << i << ") ? parallel_out" << i << " : " << T << "'bz;"<< endl;
   }


   os << "endmodule" << endl << endl;
}

// Parts 1 and 2
// Here is where you add your code to produce a neural network layer.
void genFCLayer(int M, int N, int T, int R, int P, vector<int>& constVector, string modName, ofstream &os) {

   int MAddrBits  = ceil(log2(M*N)); //matrix addrss bits
   int NAddrBits = ceil(log2(N)); // vector address bits
   int selAddrBits = ceil(log2(P));
   
   os << "`include \"controlFSM.sv\"" << endl;
   os << "`include \"datapath.sv\"" << endl;
   os << "`include \"memory.sv\"" << endl << endl;

   os << "module " << modName << "(clk, reset, input_valid, input_ready, input_data, output_valid, output_ready, output_data);" << endl << endl;
   os <<
         "\tparameter M = " << M << ";" <<endl <<
         "\tparameter N = " << N << ";" <<endl <<
         "\tparameter T = " << T << ";" <<endl <<
         "\tparameter R = " << R << ";" << endl <<
         "\tlocalparam LOGSIZE_M = $clog2(M*N);" << endl <<
         "\tlocalparam LOGSIZE_N = $clog2(N);" << endl << endl <<
         "\tinput clk, reset, input_valid, output_ready;" << endl <<
         "\tinput signed [T-1 : 0] input_data;" << endl <<
         "\toutput signed [T-1 : 0] output_data;" << endl <<
         "\toutput output_valid, input_ready;"
      << endl << endl;

   os << "\tlogic unsigned [" << selAddrBits-1 << " : 0] sel;" << endl << endl;    

   for(int i = 0; i < P; i++)
   {
      os << "\tlogic signed [T-1 : 0] parallel_out" << i << ";" << endl;
   }   
   os << endl;

   os << "\tlogic unsigned["<< NAddrBits-1 << " : 0] addr_x;" << endl;
   os << "\tlogic signed [" << T - 1 << " : 0] v_out;" << endl;
   os << "\tlogic unsigned wr_en_x;" << endl << endl;


   os << "\tlogic unsigned[" << MAddrBits-1 << " : 0] addr;" << endl << endl;
   for(int i = 0; i < P; i++)
   {
      os << "\tlogic unsigned["<< MAddrBits-1 << " : 0] addr_w" << i << ";" << endl;
      os << "\tlogic signed [" << T - 1 << " : 0] m_out" << i << ";" << endl << endl;
   }
   
   
   os << "\tlogic unsigned clear_acc;" << endl;
   os << "\tlogic unsigned en_acc;" << endl << endl;


   //******always_comb starts here
   os << "\talways_comb begin" << endl;
   for(int i = 0; i < P; i++)
   {
      os << "\t\taddr_w" << i << " = " << "addr + " << N*i << ";" << endl;
   }
   os << "\tend" << endl << endl; 
   //******always_comb ends here

   //control mod instantiation starts
   os << "\tcontrolFSM #(" << M << "," << N  << "," << P <<") controlMod(.clk(clk), .reset(reset), .input_valid(input_valid), .output_ready(output_ready)," << endl;
   os << "\t\t\t\t\t\t\t\t\t.addr_x(addr_x) , .wr_en_x(wr_en_x),.addr_w(addr), .en_acc(en_acc), .clear_acc(clear_acc)," << endl;
   os << "\t\t\t\t\t\t\t\t\t.input_ready(input_ready), .output_valid(output_valid), .countToP(sel));" << endl << endl;
   //control mod instantiation ends

   //memory mod instantiation starts
   os << "\tmemory #(" << T << ", "<< N << " ) " << " vector(.clk(clk), .data_in(input_data), .data_out(v_out), .addr(addr_x), .wr_en(wr_en_x));" << endl << endl;
   //memory mod instantiation ends

   //mux module begin
   os << "\tmux #(" << T << ", " << P << ") muxMod(";
   for(int i = 0; i < P; i++)
   {
      os << ".parallel_out" << i << "(parallel_out" << i << "), ";
   }
   os << ".sel(sel), .f(output_data));" << endl << endl;;
   //mux module ends

   //datapath mod instantiation starts
   for(int i = 0; i < P; i++)
   {
      os << "\tdatapath #(" << T << ", " << R <<") datapathMod"<< i << "(.clk(clk), .reset(reset), .m_out(m_out"<< i <<"), .v_out(v_out),.en_acc(en_acc)," << endl;
      os << "\t\t\t\t\t\t\t\t\t.output_data(parallel_out" << i << "), .clear_acc(clear_acc), .output_valid(output_valid)," << endl;
      os << "\t\t\t\t\t\t\t\t\t.output_ready(output_ready));" << endl << endl;
   }
   //datapath mod instantiation ends

   //rom mod instatiation starts
   os << "\t" << modName << "_W_rom  matrixRom(.clk(clk)," ;//  .addr(addr_w), .z(m_out));" << endl << endl;
   for(int i = 0; i < P; i++)
   {
      os << ".addr" << i << "(addr_w" << i << "), ";
   }
   for(int i = 0; i < P; i++)
   {
      if(i != P-1)
      {
         os << ".z" << i << "(m_out" << i << "), ";
      }
      else os << ".z" << i << "(m_out" << i << "));" << endl << endl;
   }
   //rom mod instantiation ends
   
   os << "endmodule" << endl << endl;

   // At some point you will want to generate a ROM with values from the pre-stored constant values.
   // Here is code that demonstrates how to do this for the simple case where you want to put all of
   // the matrix values W in one ROM. This is probably what you will need for P=1, but you will want 
   // to change this for P>1. Please also see some examples of splitting these vectors in the Part 3
   // code.


   // Check there are enough values in the constant file.
   if (M*N != constVector.size()) {
      cout << "ERROR: constVector does not contain correct amount of data for the requested design" << endl;
      cout << "The design parameters requested require " << M*N+M << " numbers, but the provided data only have " << constVector.size() << " constants" << endl;
      assert(false);
   }

   //generate a mux to output the vector elements serially
   string muxName ="mux";
   genMux(muxName, P, T, os);


   // Generate a ROM (for W) with constants 0 through M*N-1, with T bits
   string romModName = modName + "_W_rom";
   genROM(constVector, T, romModName, P, os);

}

// Part 3: Generate a hardware system with three layers interconnected.
// Layer 1: Input length: N, output length: M1
// Layer 2: Input length: M1, output length: M2
// Layer 3: Input length: M2, output length: M3
// B is the number of multipliers your overall design may use.
// Your goal is to build the fastest design that uses B or fewer multipliers
// constVector holds all the constants for your system (all three layers, in order)
void genNetwork(int N, int M1, int M2, int M3, int T, int R, int B, vector<int>& constVector, string modName, ofstream &os) {

   // Here you will write code to figure out the best values to use for P1, P2, and P3, given
   // B. 
   int P1 = 1; // replace this with your optimized value
   int P2 = 1; // replace this with your optimized value
   int P3 = 1; // replace this with your optimized value

   // output top-level module
   os << "module " << modName << "();" << endl;
   os << "   // this module should instantiate three layers and wire them together" << endl;
   os << "endmodule" << endl;
   
   // -------------------------------------------------------------------------
   // Split up constVector for the three layers
   // layer 1's W matrix is M1 x N
   int start = 0;
   int stop = M1*N;
   vector<int> constVector1(&constVector[start], &constVector[stop]);

   // layer 2's W matrix is M2 x M1
   start = stop;
   stop = start+M2*M1;
   vector<int> constVector2(&constVector[start], &constVector[stop]);

   // layer 3's W matrix is M3 x M2
   start = stop;
   stop = start+M3*M2;
   vector<int> constVector3(&constVector[start], &constVector[stop]);

   if (stop > constVector.size()) {
      os << "ERROR: constVector does not contain enough data for the requested design" << endl;
      os << "The design parameters requested require " << stop << " numbers, but the provided data only have " << constVector.size() << " constants" << endl;
      assert(false);
   }
   // --------------------------------------------------------------------------


   // generate the three layer modules
   string subModName1 = "l1_fc_" + to_string(M1) + "_" + to_string(N) + "_" + to_string(T) + "_" + to_string(R) + "_" + to_string(P1);
   genFCLayer(M1, N, T, R, P1, constVector1, subModName1, os);

   string subModName2 = "l2_fc_" + to_string(M2) + "_" + to_string(M1) + "_" + to_string(T) + "_" + to_string(R) + "_" + to_string(P2);
   genFCLayer(M2, M1, T, R, P2, constVector2, subModName2, os);

   string subModName3 = "l3_fc3_" + to_string(M3) + "_" + to_string(M2) + "_" + to_string(T) + "_" + to_string(R) + "_" + to_string(P3);
   genFCLayer(M3, M2, T, R, P3, constVector3, subModName3, os);

}


void printUsage() {
  cout << "Usage: ./gen MODE ARGS" << endl << endl;

  cout << "   Mode 1 (Part 1): Produce one neural network layer (unparallelized)" << endl;
  cout << "      ./gen 1 M N T R const_file" << endl << endl;

  cout << "   Mode 2 (Part 2): Produce one neural network layer (parallelized)" << endl;
  cout << "      ./gen 2 M N T R P const_file" << endl << endl;

  cout << "   Mode 3 (Part 3): Produce a system with three interconnected layers" << endl;
  cout << "      ./gen 3 N M1 M2 M3 T R B const_file" << endl;
}
