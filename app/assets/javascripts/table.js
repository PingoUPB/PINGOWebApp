function tableDraw()
        {this.span();

         var props = "";
         var i = 0;
         var dummyRows = this.content.length;
         var dummyCols = this.content[0].length;

         var dummyCode = '<table';
         for (prop in this)
                 {if (i >= this.propsLengthPublic) {break;}
                  dummyCode = dummyCode+' '+prop+'="'+this[prop]+'"';i++;
                }
         dummyCode = dummyCode+'>\n';

         for (var i=1;i<=dummyRows;i++)
                {dummyCode = dummyCode+'<tr>\n';
                 for (var k=1;k<=dummyCols;k++)
                        {if (this.content[(i-1)][(k-1)][2] == "false")
                                {dummyCode = dummyCode+'        <td '+this.content[(i-1)][(k-1)][0]+'>'+this.content[(i-1)][(k-1)][1]+'</td>\n';}
                        }
                 dummyCode = dummyCode+'</tr>\n';
                }

         dummyCode = dummyCode+'</table>\n';
         return dummyCode;
        }

function tableSpan()
        {var dummyRows = this.content.length;
         var dummyCols = this.content[0].length;

         for (var i=1;i<=dummyRows;i++)
                {var rowspan = 0;var colspan = 0;
                 var fromHere = 0;var tillThere = 0;
                 var myString = "";
                 for (var k=1;k<=dummyCols;k++)
                        {rowspan = 0;colspan = 0;
                         if (this.content[(i-1)][(k-1)][2] == "false")
                                {myString = (this.content[(i-1)][(k-1)][0]) + "";
                                 if (myString.indexOf("colspan") >= 0)
                                        {fromHere = (myString.indexOf("colspan"))+9;
                                         tillThere = (myString.indexOf('"',fromHere))-1;
                                         if ((fromHere-tillThere) == 0)
                                                {colspan = myString.charAt(fromHere);}
                                         else
                                                 {colspan = myString.substring(fromHere,tillThere);}
                                         colspan = parseInt(colspan);
                                        }
                                 if (myString.indexOf("rowspan") >= 0)
                                        {fromHere = (myString.indexOf("rowspan"))+9;
                                         tillThere = (myString.indexOf('"',fromHere))-1;
                                         if ((fromHere-tillThere) == 0)
                                                {rowspan = myString.charAt(fromHere);}
                                         else
                                                 {rowspan = myString.substring(fromHere,tillThere);}
                                         rowspan = parseInt(rowspan);
                                        }
                                 if ((colspan >= 2) && (rowspan <= 1))
                                        {for (var m=2;m<=colspan;m++)
                                                {this.content[(i-1)][((k-1)+(m-1))][2] = "true";}
                                        }
                                 if ((rowspan >= 2) && (colspan <= 1))
                                        {for (var m=2;m<=rowspan;m++)
                                                {this.content[((i-1)+(m-1))][(k-1)][2] = "true";}
                                        }
                                 if ((rowspan >= 2) && (colspan >= 2))
                                        {for (var m=1;m<=rowspan;m++)
                                                {for (var p=1;p<=colspan;p++)
                                                        {this.content[((i-1)+(m-1))][((k-1)+(p-1))][2] = "true";}
                                                }
                                         this.content[(i-1)][(k-1)][2] = "false";
        }        }        }        }        }

function tableContent(dummyCols,dummyRows)
        {var dummyContent = "[";
         for (var i=1;i<=dummyRows;i++)
                {dummyContent = dummyContent+"["
                 for (var k=1;k<=dummyCols;k++)
                        {dummyContent = dummyContent+"[['align="+'"left"'+" valign="+'"top"'+"'],[' '],['false']],";}
                 dummyContent = dummyContent.substring(0,((dummyContent.length)-1));
                 dummyContent = dummyContent+"],"
                }
         dummyContent = dummyContent.substring(0,((dummyContent.length)-1));
         dummyContent = dummyContent+"]";
         return eval(dummyContent);
        }

function tableContentArraysToArguments()
        {var dummyRows = this.content.length;
         var dummyCols = this.content[0].length;
         for (var i=1;i<=dummyRows;i++)
                {for (var k=1;k<=dummyCols;k++)
                        {this.content[(i-1)][(k-1)].props = this.content[(i-1)][(k-1)][0];
                         this.content[(i-1)][(k-1)].value = this.content[(i-1)][(k-1)][1];
                         this.content[(i-1)][(k-1)].spans = this.content[(i-1)][(k-1)][2];
        }        }        }

function tableContentArgumentsToArrays()
        {var dummyRows = this.content.length;
         var dummyCols = this.content[0].length;
         for (var i=1;i<=dummyRows;i++)
                {for (var k=1;k<=dummyCols;k++)
                        {this.content[(i-1)][(k-1)][0] = this.content[(i-1)][(k-1)].props;
                         this.content[(i-1)][(k-1)][1] = this.content[(i-1)][(k-1)].value;
                         this.content[(i-1)][(k-1)][2] = this.content[(i-1)][(k-1)].spans;
        }        }        }

function table()
        {var propsDefaultLength = 2;
         this.cols = 1;
         this.rows = 1;
         for (var i=1;i<=table.arguments.length;i++)
                {if (table.arguments[(i-1)].indexOf("cols") >= 0) {propsDefaultLength--;}
                 if (table.arguments[(i-1)].indexOf("rows") >= 0) {propsDefaultLength--;}
                 eval("this."+table.arguments[(i-1)]);
                }
         this.propsLengthPublic = (table.arguments.length + propsDefaultLength);
         this.propsLengthPrivat = 7;
         this.content = tableContent(this.cols,this.rows);
         this.span = tableSpan;
         this.draw = tableDraw;
         this.contentArraysToArguments = tableContentArraysToArguments;
         this.contentArgumentsToArrays = tableContentArgumentsToArrays;
        }