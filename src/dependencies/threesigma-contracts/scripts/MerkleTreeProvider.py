import sys
from functools import reduce
from utils.merkletools import MerkleTools


class FFIProvider():

    def output_int(self, integer):
        sys.stdout.write(str(hex(integer)[2:]).zfill(64))

    def output_string(self, string):
        sys.stdout.write(string)

    def output_addresses(self, filename):
        addresses = [] 
        with open(filename, "r") as f:
            for line in f.readlines():
                addresses += [self.encodeLeaf(line)]
        
        sys.stdout.write("".join(addresses))
    
    def output_int_array(self, filename):
        integers = [] 
        with open(filename, "r") as f:
            for line in f.readlines():
                integers += [int(line, 16)] 
        result = reduce(lambda x, y :  str(x) + str(y) , integers)
        
        sys.stdout.write(result)
    
    def output_string_array(self, filename):
        strings = []
        with open(filename, "r") as f:
            for line in f.readlines():
                strings += [self.encodeLeaf(line)] 

        sys.stdout.write("".join(strings))
    
    def output_merkle_proofs_length(self, filename):

        with open(filename, "r") as f:
            n_leafs = len(f.readlines())
        
        mt = MerkleTools()

        mt.add_leaf([str(i).encode() for i in range(int(n_leafs))], True)
        mt.make_tree()
        lengths = [hex(len(mt.get_proof(i)))[2:] for i in range(int(n_leafs))]
        lengths = list(map(lambda x : str(x).zfill(8), lengths))

        sys.stdout.write("".join(lengths))


    def output_merkle_proofs(self, filename):

        mt = MerkleTools()
        whitelists_bytes = []
        whitelists = []
        with open(filename, "r") as f:
            for line in f.readlines():
                encodedLeaf = self.encodeLeaf(line)
                whitelists_bytes += [bytes.fromhex(encodedLeaf)] 
                whitelists += [encodedLeaf]

        mt.add_leaf(whitelists_bytes, True)
        mt.make_tree()

        for i in range(len(whitelists)):
            this_proof=[]

            proof_dicts=mt.get_proof(i) 
            for dict in proof_dicts:
                #Builds a list containing the proofs of 1 address
                val = list(dict.values())[0]
                this_proof.append(val)
            #Appends that list to the list global proofs
        
            sys.stdout.write("".join(this_proof))

    def output_merkle_root(self,filename):
        leafs = []
        with open(filename, "r") as f:
            for line in f.readlines():
                leafs += [self.encodeLeaf(line)]
        # print(leafs)
        leafs = list(map(lambda x: bytes.fromhex(x), leafs))
        mt = MerkleTools()

        mt.add_leaf(leafs, True)
        mt.make_tree()
        root=mt.get_merkle_root()
        sys.stdout.write(root)

    def encodeLeaf(self,line):
        address = line[2:42]
        return address

if __name__ == "__main__":

    func_name = sys.argv[1]
    arg2 = sys.argv[2]

    provider = FFIProvider()
    func = getattr(provider, func_name)
    func(arg2)
