from pathlib import Path
import argparse,json
def collect(path):
    tasks={};invalid=0
    if path.exists():
        for line in path.read_text(errors="replace").splitlines():
            if line.startswith("#") or not line.strip():continue
            columns=line.split("\t")
            if len(columns)<5:invalid+=1;continue
            try:start,end=int(columns[0]),int(columns[1])
            except ValueError:invalid+=1;continue
            if end<start:invalid+=1;continue
            output=columns[3];suffix=Path(output).suffix.lower()
            category="compile" if suffix in (".o",".obj") else "link" if suffix in (".exe",".dll",".so",".dylib") else "archive" if suffix in (".lib",".a") else "pch" if suffix in (".pch",".gch") else "other"
            if suffix=="" and "/bin/" in "/"+output.replace("\\","/"):category="link"
            tasks[output]={"output":output,"category":category,"start_ms":start,"end_ms":end,"seconds":round((end-start)/1000,3)}
    rows=sorted(tasks.values(),key=lambda x:x["seconds"],reverse=True)
    return {"ninja_log_present":path.exists(),"invalid_records":invalid,"task_count":len(rows),"category_seconds_sum":{c:round(sum(x["seconds"] for x in rows if x["category"]==c),3) for c in ("compile","link","archive","pch","other")},"note":"Task durations can overlap; sums are not build wall time.","tasks":rows}
if __name__=="__main__":
    p=argparse.ArgumentParser();p.add_argument("build_dir",type=Path);p.add_argument("output",type=Path);a=p.parse_args();a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(collect(a.build_dir/".ninja_log"),indent=2)+"\n")
