//ProBT PLUS BINARY-7 Release Version 1.1 Alpha
//Programmer LeeJAJA
//Date 27.9.13

uses dos,crt;

label hea;								//用于软件化后可以多次调用程序而设的指针

const
	Binaryk = 7;
	//Path = 'C:\Binary-7';

type
	haff = record
		times		: qword;
		cha		: char;
		code		: ansistring;
	end;								//专门用于存放各种字符的类型

	tree = record
		cha		: char;
		int		: longint;
		left,right	: longint;
	end;								//Haffman树的节点类型 int指以此节点为根节点的子树的总频率

var
        Path                    : ansistring;
	haffmantree		: array[0..1000000] of tree;		//Haffman树
	queue			: array[0..1000000] of longint;		//构建Haffman树时所使用的单调队列
	a			: array[0..1000000] of haff;      	//存放各种字符出现个数的基本数组
	k1			: array[1..1000000] of ansistring;
	k2			: array[1..1000000] of char;
	qn		        : longint;
	ch			: set of char;				//优化init单元的字符集合 读入时判重剪枝
	n			: longint;				//n是总结点数
	f,flag			: boolean;				//flag是指DFS时的剪枝变量
	qs			: string;				//qs是DFS时用于记录路径并输出
	inputname,outputname	: ansistring;
        f1,f2                   : text;

procedure prepare;
var
        rdk                     : char;
        Stat                    : longint;

begin
        Stat:=0;
        while true do begin
                textbackground(blue);
                textcolor(LightGray);
                clrscr;
                gotoxy(29,4);
                textbackground(red);
                TextColor(LightGray);
                Textcolor(blue);
                write('   Install/Reinstall   ');

                gotoxy(29,13);
                textbackground(LightGray);
                Textcolor(blue);
                write(' Default ');

                gotoxy(45,13);
                write(' Custom ');

                gotoxy(3,23);
                writeln(' BACK ');

                textcolor(LightGray);
                gotoxy(29,25);
                textbackground(blue);
                write('<Default Path is ''C:\''>');


                textbackground(red);
                textcolor(LightGray);
                if Stat=1 then begin
                        gotoxy(29,13);
                        write(' Default ');
                end;

                if Stat=2 then begin
                        gotoxy(45,13);
                        write(' Custom ');
                end;

                if Stat=3 then begin
                        gotoxy(3,23);
                        writeln(' BACK ');
                end;

                rdk:=readkey;

              {  Stat:=1;
                rdk:=chr(13); }

              {  rdk:=chr(13);
                Stat:=2;  }
                if (ord(rdk)=75) and (Stat>=2) then dec(Stat);
                if (ord(rdk)=77) and (Stat<=2) and (Stat<>0) then inc(Stat);
                if (ord(rdk)=72) and (Stat=3) then Stat:=1;
                if (ord(rdk)=80) and (Stat in [1,2]) then Stat:=3;
                if (ord(rdk) in [75,77,72,80]) and (Stat=0) then Stat:=1;
                if (Stat<>0) and (ord(rdk)=13) then begin
                        if Stat=3 then exit;
                        if Stat=1 then Path:='C:\Binary-7 Compressor';
                        if Stat=2 then while true do begin
                                textbackground(blue);
                                clrscr;
                                textbackground(yellow);
                                textcolor(lightgreen);
                                gotoxy(35,4);
                                write(' Custom ');

                                gotoxy(8,15);
                                textbackground(green);
                                textcolor(Lightred);
                                write('Custom Path:                                                  ');
                                gotoxy(20,15);
                                readln(Path);
                                Path:=Path+'\Binary-7 Compressor';
                                break;
                        end;
                        break;
                end;
        end;
	if fsearch('Example.in',path+'\Compress'+'\Input')='' then begin
		MKdir(path);
        MKdir(path+'\Compress');
        Mkdir(path+'\Uncompress');
        MKdir(path+'\Compress'+'\Input');
        MKdir(path+'\Compress'+'\Output');
        MKdir(path+'\Uncompress'+'\Input');
        MKdir(path+'\Uncompress'+'\Output');
        assign(output,path+'\Compress\Input'+'\Example.in'); rewrite(output);
		writeln('I LOVE Binary-7 Compressor!!! O(∩_∩)O~~');
		close(output);
	end;
        assign(f1,'C:\B7\Path.o'); rewrite(f1);
        writeln(f1,path);
        close(f1);

	textbackground(blue);
	clrscr;
	gotoxy(21,10);
	textbackground(yellow);
	textcolor(red);
	write('Install Completed Successfully! O(*_*)O~~');
	gotoxy(27,25);
	textbackground(blue);
	textcolor(Lightgray);
	write('Press Any Key To Continue');
	readkey;
end;

procedure sort(l,r		: longint);
var
	i,j,x,p			: longint;
	y			: longint;

begin
 	i:=l;
        j:=r;
        x:=Haffmantree[queue[(l+r) div 2]].int;
        repeat
           	while Haffmantree[queue[i]].int>x do inc(i);
           	while x>Haffmantree[queue[j]].int do dec(j);
           	if not(i>j) then begin
                	y:=queue[i];
                	queue[i]:=queue[j];
                	queue[j]:=y;
                	inc(i);
                	dec(j);
             	end;
        until i>j;
        if l<j then sort(l,j);
        if i<r then sort(i,r);
end;									//快排 单调队列维护

procedure init;
var
	cc			: char;
	i			: longint;

begin
	if pos('.B7',inputname)=0 then assign(f1,path+'\Compress'+'\Input'+'\'+inputname); reset(f1);
	ch:=[];
	n:=0;
	while not eof(f1) do begin
		read(f1,cc);
                //writeln(ord(cc));
                //if (ord(cc)<32) or (ord(cc) in [239,187,191]) then continue;
		if not(cc in ch) then begin
			inc(n);
			ch:=ch+[cc];
			a[n].cha:=cc;
			a[n].times:=1;
		end
		else for i:=1 to n do
			if a[i].cha=cc then begin
				inc(a[i].times);
				break;
			end;
	end;
	close(f1);
end;									//初始化单元

procedure Haffman;
var
	i			: longint;
	c,k			: longint;				//c是维护单调队列queue时的辅助变量（即队列中当时元素个数） k是当前Haffman树的节点个数

begin
	k:=n;
        c:=n;
	for i:=1 to n do begin
		Haffmantree[i].left:=-1;
		Haffmantree[i].right:=-1;
		Haffmantree[i].cha:=a[i].cha;
		Haffmantree[i].int:=a[i].times;
	end;
	for i:=1 to n do queue[i]:=i;

	while c<>1 do begin
		sort(1,c);
		inc(k);
		dec(c);
		Haffmantree[k].left:=queue[c+1];
		Haffmantree[k].right:=queue[c];
		Haffmantree[k].int:=Haffmantree[queue[c+1]].int+Haffmantree[queue[c]].int;
		queue[c]:=k;
	end;								//构建Haffman树
end;

procedure DFS(k,qc		: longint);
var
	i			: char;

begin
	if Flag then exit;

	if Haffmantree[k].cha=a[qc].cha then begin
		Flag:=false;
		writeln(f2,ord(a[qc].cha),' ',qs);
		a[qc].code:=qs;
		exit;
	end;

	for i:='0' to '1' do begin
		qs:=qs+i;
		if (i='0') and (Haffmantree[k].left>0) then DFS(Haffmantree[k].left,qc);
		if (i='1') and (Haffmantree[k].right>0) then DFS(Haffmantree[k].right,qc);
		delete(qs,length(qs),1);
	end;
end;                                                                 //check单元用于检查Haffman树构造情况

procedure search(s		: ansistring);
var
	i,now			: qword;

begin
		i:=0;
		now:=queue[1];						//从Haffman树的根节点开始找起
		while i<>length(s)+1 do begin
			inc(i);
			if Haffmantree[now].cha in ch then begin
				write(Haffmantree[now].cha);
				now:=queue[1];				//找到目标节点再次从根节点开始循环
			end;
                        if i=length(s)+1 then exit;
			if s[i]='0' then begin
				now:=Haffmantree[now].left;
				continue;
			end;
			if s[i]='1' then begin
				now:=Haffmantree[now].right;
				continue;
			end;
		end;
end;									//开发人员检测压缩是否正确

procedure Haffcom;
var
	strin,strout		: ansistring;
	qstr			: ansistring;				//qstr用于每次取出八位二进制
	k,i,j                   : longint;
        ascll                   : qword;

begin
	assign(f1,path+'\Compress'+'\Input'+'\'+Inputname); reset(f1);
	assign(f2,path+'\Compress'+'\Output'+'\'+outputname); rewrite(f2);
	writeln(f2,Inputname);

	writeln(f2,n);
	for i:=1 to n do begin
                Flag:=false;
                DFS(queue[1],i);
        end;
	while not eof(f1) do begin
		readln(f1,strin);
                strout:='';
		for i:=1 to length(strin) do
			for j:=1 to n do
				if strin[i]=a[j].cha then begin
					strout:=strout+a[j].code;
					break;
				end;
				//writeln(strout);
				k:=Binaryk-length(strout) mod Binaryk;
                                if k=Binaryk then k:=0;
				writeln(f2,k);
                                for i:=1 to k do strout:=strout+'0';
				for i:=1 to (length(strout)+k) div Binaryk do begin
					ascll:=32;
					qstr:=copy(strout,Binaryk*(i-1)+1,Binaryk);
					for j:=1 to Binaryk do
						if qstr[j]='1' then ascll:=ascll+trunc(exp(ln(2)*(Binaryk-j)));
					write(f2,chr(ascll));
				end;
				writeln;
	end;
	close(f1); close(f2);
end;									//Haffcom用于对文件进行压缩 本单元采用Binary-7压缩

procedure Comsearch(s		: ansistring);
var
	ps			: ansistring;
	i,j			: longint;

begin
	ps:='';
	for i:=1 to length(s) do begin
		ps:=ps+s[i];
                for j:=1 to qn do
		if k1[j]=ps then begin
			write(f2,k2[j]);
                        ps:='';
			break;
		end;
	end;
end;

procedure HaffRecom;
var
	q			: char;					//读入字符与其haffman编码之间的空格
	k,asc                   : int64;
        s,as,ps                 : ansistring;
        i                       : longint;

begin
	assign(f1,path+'\Uncompress'+'\Input'+'\'+inputname); reset(f1);
	readln(f1,outputname);
	assign(f2,path+'\Uncompress'+'\Output'+'\'+outputname); rewrite(f2);
	readln(f1,qn);
	for i:=1 to qn do begin
                read(f1,k);
                k2[i]:=chr(k);
                read(f1,q);
                readln(f1,k1[i]);
	end;
        while not eof(f1) do begin
                readln(f1,k);
                readln(f1,s);
                for i:=1 to length(s) do begin
                        asc:=ord(s[i])-32;
                        ps:='';
                        while asc>1 do begin
                                if asc mod 2=1 then ps:='1'+ps
                                else ps:='0'+ps;
                                asc:=asc div 2;
                        end;
                        if asc=1 then ps:='1'+ps
                        else ps:='0'+ps;
                        while length(ps)<Binaryk do ps:='0'+ps;
                        as:=as+ps;
                end;
                delete(as,length(as)-k+1,k);
                //writeln(as);
                comsearch(as);
                as:='';
                writeln;
        end;
	close(f1); close(f2);
end;


procedure readname;
var
        rdk                     : char;
        Stat                    : longint;
		i						: longint;
		//f						: boolean;		//用于直接退出

begin
        assign(f1,'C:\B7\Path.o'); reset(f1);
             readln(f1,Path);
             close(f1);
        Stat:=0;
		f:=false;

		while true do begin
				if f then exit;
                textbackground(blue);
                textcolor(LightGray);
                clrscr;
				gotoxy(8,12);
                textbackground(green);
                textcolor(Lightred);
                write('Input File Name:                                                  ');
				gotoxy(24,12);
				readln(Inputname);

				if fsearch(Inputname,path+'\Compress'+'\Input')<>'' then begin
					outputname:=inputname;
					i:=length(outputname);
					if pos('.',outputname)<>0 then begin
						while outputname[i]<>'.' do begin
							delete(outputname,i,1);
							dec(i);
						end;
						outputname:=outputname+'B7';
					end;
					exit;
				end
				else begin
                                        if pos('.B7',inputname)<>0 then exit;

					textbackground(blue);
					clrscr;

					gotoxy(24,10);
					textbackground(yellow);
					textcolor(red);
					write('Sorry,I can''t find this file >_<');

					while true do begin
						gotoxy(14,20);
						textbackground(LightGray);
						Textcolor(blue);
						write(' Back ');

						gotoxy(55,20);
						write(' Try Again ');

						textbackground(red);
						textcolor(LightGray);

						if Stat=1 then begin
								gotoxy(14,20);
								write(' Back ');
						end;

						if Stat=2 then begin
								gotoxy(55,20);
								write(' Try Again ');
						end;

						rdk:=readkey;

						if (Stat=0) and (ord(rdk) in [77,75]) then Stat:=1;
						if ord(rdk)=75 then Stat:=1;
						if ord(rdk)=77 then Stat:=2;
						if ord(rdk)=13 then begin
							if Stat=1 then begin
								f:=true;
								exit;
							end;
							if Stat=2 then begin
                                                                Stat:=0;
                                                                break;
                                                        end;
						end;
					end;
				end;
        end;
end;

procedure main;
var
        Stat                    : longint;
        rdk                     : char;

begin
        clrscr;
        Stat:=0;
        window(1,1,80,25);
        while true do begin
                 textbackground(blue);
                 textcolor(lightGray);
                 clrscr;
                 textcolor(11);
                 textbackground(14);
                 gotoxy(27,3);
                 write('                           ');
                 gotoxy(27,5);
                 write('                           ');
                 gotoxy(23,4);
                 write('  ---===Binary-7 Compressor===---  ');
                 textbackground(green);
                 textcolor(LightGray);
                 gotoxy(30,6);
                 write('Programmer: LeeJAJA ');
                 gotoxy(27,25);
                 textbackground(red);
                 write('   Powered BY Pro-BT PLUS   ');

                 gotoxy(31,11);
                 textbackground(Lightgray);
                 TextColor(blue);
                 write(' Install/Reinstall ');
                 textbackground(blue);

                 gotoxy(36,13);
                 textbackground(Lightgray);
                 TextColor(blue);
                 write(' Compress ');
                 textbackground(blue);

                 gotoxy(35,15);
                 textbackground(Lightgray);
                 TextColor(blue);
                 write(' Uncompress ');
                 textbackground(blue);

                 gotoxy(38,17);
                 textbackground(Lightgray);
                 TextColor(blue);
                 write(' Exit ');
                 textbackground(blue);

                 if Stat=1 then begin
                        gotoxy(31,11);
                        textbackground(red);
                        TextColor(LightGray);
                        write(' Install/Reinstall ');
                 end;
                 if Stat=2 then begin
                        gotoxy(36,13);
                        textbackground(red);
                        TextColor(Lightgray);
                        write(' Compress ');
                        textbackground(blue);
                 end;
                 if Stat=3 then begin
                        gotoxy(35,15);
                        textbackground(red);
                        TextColor(lightgray);
                        write(' Uncompress ');
                        textbackground(blue);
                 end;
                 if Stat=4 then begin
                        gotoxy(38,17);
                        textbackground(red);
                        TextColor(Lightgray);
                        write(' Exit ');
                        textbackground(blue);
                 end;

                 rdk:=readkey;
                 gotoxy(1,1);

                 {Stat:=3;
                 rdk:=chr(13); }

                 //writeln(rdk);
                 if (ord(rdk)=80) and (Stat>0) and (Stat<=3) then inc(Stat);
                 if (ord(rdk)=72) and (Stat>=2) and (Stat<=4) then dec(Stat);
                 if (ord(rdk) in [80,72]) and (Stat=0) then Stat:=1;
                 if ord(rdk)=13 then begin
                        if Stat=4 then halt;
                        if Stat=1 then prepare;
						if Stat=2 then begin
							readname;
							if not(f) then begin
                                                        init;
                                                        Haffman;
                                                        Stat:=0;
                            							textbackground(blue);
														clrscr;
														gotoxy(21,10);
														textbackground(yellow);
														textcolor(red);
														write('Compress Completed Successfully! O(*_*)O~~');
														gotoxy(27,25);
														textbackground(blue);
														textcolor(Lightgray);
														write('Press Any Key To Continue');
														readkey;
                                                        end;
							if (not(f)) and (ch<>[]) then Haffcom;
                                                        Stat:=0;
                            							textbackground(blue);
														clrscr;
														gotoxy(21,10);
														textbackground(yellow);
														textcolor(red);
														write('Uncompress Completed Successfully! O(*_*)O~~');
														gotoxy(27,25);
														textbackground(blue);
														textcolor(Lightgray);
														write('Press Any Key To Continue');
														readkey;
						end;
                 end;
        end;
end;

procedure pre;
begin
     if fsearch('Path.o','C:\B7\')='' then begin
        Mkdir('C:\B7');
        assign(f2,'C:\B7\Path.o'); rewrite(f2);
        writeln('C:\Binary-7 Compressor');
        close(f2);
     end;
end;

begin
        pre;
	main;
	prepare;
	init;
	if ch<>[] then Haffman;
	Haffcom;
	HaffRecom;
end.
