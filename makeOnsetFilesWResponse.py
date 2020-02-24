import os,csv

savs=[]
directory='/mnt/BIAC/munin2.dhe.duke.edu/Meade/DECIDE.01/Notes/CSVtest'
runs=['1','2','3']
for fil in os.listdir(directory):
	savs.append(os.path.join(directory,fil))

for sav in savs:
	#f = open(sav)
	for run in runs:
		lis=[]
		variables = {
		 'Ambig_certain': [],
		 'Ambig_uncertain': [],
		 'Ambig_missed': [],
		 'Risky_certain': [],
		 'Risky_uncertain': [],
		 'Risky_missed': []}

		f = open(sav)
		for line in f:
			#print(line)

			line = line.strip('\n')
			new_line=line.split(',')
			if str(new_line[14]) == str(run):
				lis.append(new_line)
				flag=sav.find("4")
				subjectname=sav[flag:flag+4]

				onset_correction_1 = float(lis[0][0])

				if new_line[2]=='4':
					if new_line[8]=='1':
						variables['Ambig_certain'].append(new_line)
					if new_line[8]=='2':
						variables['Ambig_uncertain'].append(new_line)
					if new_line[8]=='0':
						variables['Ambig_missed'].append(new_line)

				if new_line[2]=='3':
					if new_line[8]=='1':
						variables['Risky_certain'].append(new_line)
					if new_line[8]=='2':
						variables['Risky_uncertain'].append(new_line)
					if new_line[8]=='0':
						variables['Risky_missed'].append(new_line)

		for key,value in variables.items():
			if len(value) == 0:
				pass
			else:
				#print('run: %s\nkey: %s\nvalue: %s'%(run,key,value))
				with open("/mnt/BIAC/munin2.dhe.duke.edu/Meade/DECIDE.01/Notes/AT_Timing_Responses_shana/AT_" + subjectname + "_" + key + "_" + run + ".txt","w") as csv_out:
					mywriter=csv.writer(csv_out,delimiter='\t')
					for item in value:
						clipped_item=[]
						clipped_item.append(str(float(item[0])-onset_correction_1))
						clipped_item.append(item[1])
						clipped_item.append(item[11])
						mywriter.writerow(clipped_item)
				csv_out.close()
