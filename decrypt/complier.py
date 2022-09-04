import os

print('Running Lab3:')



#fileObj = open("filename", "mode") 
filename = r"C:\Users\shang\OneDrive\Desktop\UCSD Courses\CSE141L\software\software -- lab 3\Assembly3.txt"

read_file = open(filename, "r") 

#Print read_file

#w_file is the file we are writing to

w_file = open(r"C:\Users\shang\OneDrive\Desktop\UCSD Courses\CSE141L\software\software -- lab 3\Machine3.txt", "w")


#Open a file name and read each line
#to strip \n newline chars
#lines = [line.rstrip('\n') for line in open('filename')]  

#1. open the file
#2. for each line in the file,
#3.     split the string by white spaces
#4.      if the first string == SET then op3 = 0, else op3 = 1
#5.      
with open(filename, 'r') as f:
  for line in f:
    print(line)
    str_array = line.split()
    instruction = str_array[0]

    print(instruction)
    print(str_array)

    if instruction == "BLT":
      reg1 = str_array[1]
      reg2 = str_array[2]
      ptr = str_array[3]
      if (reg1 == "r0"):
        reg1 = "00"
      elif (reg1 == "r1"):
        reg1 = "01"
      elif (reg1 == "r2"):
        reg1 = "10" 
      elif (reg1 == "r3"):
        reg1 = "11"


      if (reg2 == "r0"):
        reg2 = "000"
      elif (reg2 == "r1"):
        reg2 = "001"
      elif (reg2 == "r2"):
        reg2 = "010" 
      elif (reg2 == "r3"):
        reg2 = "011"
      elif (reg2 == "r4"):
        reg2 = "100"
      elif (reg2 == "r5"):
        reg2 = "101"
      elif (reg2 == "r6"):
        reg2 = "110"
      elif (reg2 == "r7"):
        reg2 = "111"
      
      if ptr == "6":
        ptr = "00"
      elif ptr == "14":
        ptr = "01"
      return_set = "10" + reg1 + reg2 + ptr
      w_file.write(return_set + '\n')
    elif instruction == "BGT":
      reg1 = str_array[1]
      reg2 = str_array[2]
      ptr = str_array[3]
      if (reg1 == "r0"):
        reg1 = "00"
      elif (reg1 == "r1"):
        reg1 = "01"
      elif (reg1 == "r2"):
        reg1 = "10" 
      elif (reg1 == "r3"):
        reg1 = "11"
    

      if (reg2 == "r0"):
        reg2 = "000"
      elif (reg2 == "r1"):
        reg2 = "001"
      elif (reg2 == "r2"):
        reg2 = "010" 
      elif (reg2 == "r3"):
        reg2 = "011"
      elif (reg2 == "r4"):
        reg2 = "100"
      elif (reg2 == "r5"):
        reg2 = "101"
      elif (reg2 == "r6"):
        reg2 = "110"
      elif (reg2 == "r7"):
        reg2 = "111"
      
      if ptr == "6":
        ptr = "00"
      elif ptr == "14":
        ptr = "01"
      return_set = "11" + reg1 + reg2 + ptr
      w_file.write(return_set + '\n')
    else:
      op3 = "0"      
      op1 = str_array[1]
      op2 = str_array[2]
      if instruction == "ADD": 
        opcode = "000"
        op2 = str_array[2]
      elif instruction == "AND":
        opcode = "001" 
        op2 = str_array[2]
      elif instruction == "LSL":
        opcode = "010"
        op2 = str_array[2]
      elif instruction == "ORR":
        opcode = "011"
        op2 = str_array[2]
      elif instruction == "LDR":
        opcode = "100" 
        op2 = str_array[2]
      elif instruction == "STR": 
        opcode = "101"
        op2 = str_array[2]        
      elif instruction == "SUB":
        opcode = "110"
        op2 = str_array[2]
      elif instruction == "XOR":
        opcode = "111" 
        op2 = str_array[2]        
      else:
        opcode = "error: undefined opcode"
        print("error: undefined opcode")
    

      # if ((op1 == "$t2" or op1 == "$t3" or op1 == "$t4") 
      #       or (op2 == "$t2" or op2 == "$t3" or op2 == "$t4")):
      #    level = "1"
      # else:
      #    level = "0"

      print(op1)

      if (op1 == "r0"):
        reg1 = "00"
      elif (op1 == "r1"):
        reg1 = "01"
      elif (op1 == "r2"):
        reg1 = "10" 
      elif (op1 == "r3"):
        reg1 = "11"
    

      if (op2 == "r0"):
        reg2 = "000"
      elif (op2 == "r1"):
        reg2 = "001"
      elif (op2 == "r2"):
        reg2 = "010" 
      elif (op2 == "r3"):
        reg2 = "011"
      elif (op2 == "r4"):
        reg2 = "100"
      elif (op2 == "r5"):
        reg2 = "101"
      elif (op2 == "r6"):
        reg2 = "110"
      elif (op2 == "r7"):
        reg2 = "111"

      # if op2 == "000":
      #   return_rtype = op3 + opcode + reg1 + reg2 + level \
      #               + '\t' + "#" + " " + instruction \
      #               + " " + op1 
      # else:
      #   return_rtype = op3 + opcode + reg1 + reg2 + level \
      #               + '\t' + "#" + " " + instruction \
      #               + " " + op1 + " " + op2
      return_rtype = op3 + opcode + reg1 + reg2

      w_file.write(return_rtype + '\n' )



w_file.close()
   

      


