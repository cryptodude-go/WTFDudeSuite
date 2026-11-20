# Original short gathering cues. Rebuild with Python 3, no third-party packages.
from pathlib import Path
import math, wave, struct
media=Path(__file__).resolve().parent.parent/'Media'
rate=22050; duration=.58
for name,notes,partials in [('HerbChime.wav',[(0,1046.5),(.14,1568)],[(1,1),(2,.18),(3,.06)]),('MiningChime.wav',[(0,659.25),(.12,987.77)],[(1,1),(2.76,.2),(4.1,.07)])]:
 samples=[]
 for i in range(int(rate*duration)):
  t=i/rate;value=0
  for start,freq in notes:
   u=t-start
   if u>=0:
    envelope=(1-math.exp(-u/0.005))*math.exp(-u/0.105)
    value+=envelope*sum(gain*math.sin(2*math.pi*freq*ratio*u) for ratio,gain in partials)
  value*=min(1,(duration-t)/.03)
  samples.append(value)
 peak=max(abs(v) for v in samples);samples=[int(v/peak*.38*32767) for v in samples]
 with wave.open(str(media/name),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(struct.pack('<'+'h'*len(samples),*samples))
 print(name,len(samples),'samples; peak',max(abs(v)for v in samples))
