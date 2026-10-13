# Steal a Disaster! Master design and implementation plan

**ฉบับเสนออนุมัติ 1.0 · 13 ตุลาคม 2026 · ยังไม่อนุมัติให้ Implement**

เอกสารชุดนี้ออกแบบเกมและแผนพัฒนาจากหลักฐานในเครื่อง ณ branch `main`, commit `e4b5f421a946e21e0e962bb6e4e3d6bbb380d875` รวมกับการอ่าน Studio จริงในโหมด Edit วันที่ 13 ตุลาคม 2026 ใช้คำขอล่าสุดเป็นข้อกำหนดสูงสุด ตัวเลขทั้งหมดที่เสนอเป็นค่าตั้งต้นสำหรับทดสอบ ไม่ใช่ Balance ที่ผ่านแล้ว

## 1. Executive summary

แนะนำ **Disaster Containment Crew** ผู้เล่นเป็นนักเก็บกู้ที่จับภัยพิบัติมีชีวิตลง Containment Crate แล้ววิ่งหนี Warden กลับฐาน ความสนุกหลักอยู่ที่การตัดสินใจ Stabilize หรือ Snatch การอ่านเส้นทางหนี และช่วงเปิดกล่องที่บ้าน สิ่งสะสมมีบุคลิกของภัยพิบัติแต่ละพื้นที่และสร้าง Chaos Coins เมื่อวางในฐาน

ลูปที่คงไว้คือ ฝึกบน Treadmill จริง → เข้าโซน → เลือกกล่องตาม Rarity → Stabilize หรือ Snatch → ถือกล่องหนี → เดินกลับฐานด้วยตัวเอง → เปิด → เก็บและวาง Disaster → สะสมและเก็บรายได้ → อัปเกรดและกลับไปเสี่ยงอีกครั้ง ไม่มีการส่งกล่องกลับบ้านหรือ Teleport อัตโนมัติ

**สถานะปัจจุบันเป็น Prototype ที่ยังไม่จบ P1** โค้ดมีการสร้างกล่อง จับ ถือ หนี และเปิดรับรางวัลแบบ memory-only แต่ยังไม่มี Placement, Passive Income หรือ Persistence รายได้ใน Prototype เป็นเงินก้อนจากการเปิดกล่อง เครื่องฝึกยังเป็นปุ่ม E ข้อมูลใน Studio ที่ตรวจพบไม่ตรงกับสมมติฐานว่าใส่ครบแปดสคริปต์แล้ว ดู [หลักฐานและข้อจำกัด](01-audit.md)

ให้พัฒนาตาม P1 → P2 → P3 → P4 โดยใช้ Zone 1 พิสูจน์ Core Loop และ Data Safety ก่อน P2 เพิ่ม Progression และ Theft จากนั้น P3 ผลิตแมพและงานภาพครบห้าโซน แล้ว P4 เพิ่ม Global Events ก่อนตรวจ Launch gate การเตรียมแนวภาพและบันทึก Reference ทำคู่ขนานได้ แต่ไม่ถือว่าปิด Phase ภายหลังก่อนผ่าน Phase ก่อนหน้า

MVP ภายในทีมคือ P1 ที่ครบลูปหนึ่งโซน มีเจ็ดฐานและข้อมูลถาวร Closed Beta คือ P2 พร้อมเนื้อหาทดสอบ และช่วงต้น P3 สามโซน Public launch ต้องครบ P1–P4 รวม **7 ฐาน**, **5 โซนต่อเนื่อง**, Treadmill จริง, Theft, งานภาพสำเร็จ และ Event recovery ห้ามเรียก MVP ว่า Launch-ready

## 2. วิธีใช้เป็นเอกสารกลาง

ก่อนอนุมัติ ชุดนี้เป็น **proposal** ไม่ได้แก้หรือยกเลิกประวัติใน `docs/DECISIONS.md` โดยเงียบ หลัง Head อนุมัติ ให้ Task P1-01 บันทึก version และ decision IDs ที่รับรอง แล้วชี้ `GAME_VISION.md`, `TASK_BACKLOG.md`, `MAP_CONCEPT.md` และ `STUDIO_MCP.md` มาที่ส่วนที่เกี่ยวข้อง ห้ามรักษากติกาขัดแย้งสองชุดพร้อมกัน

คำเรียกมีความหมายดังนี้

| Label | ความหมาย |
|---|---|
| LOCKED | มาจากคำขอครั้งนี้หรือการตัดสินใจที่ยืนยันแล้ว |
| VERIFIED | พบหลักฐานโดยตรง ระบุว่า source, XML หรือ live Edit |
| PARTIAL | มีบางส่วน แต่ไม่ครบกติกาเป้าหมาย |
| MISSING | ไม่พบในขอบเขต source หรือ live snapshot ที่ตรวจ |
| UNKNOWN | ยังไม่มีหลักฐานเพียงพอ ต้องมี verification step |
| PROPOSED | การตัดสินใจที่แนะนำในแผนนี้ รออนุมัติทั้งแผน |

เอกสารทั้งชุดเป็นฉบับเดียวกัน ความหมายของ entity IDs, สูตร, state และ task IDs ใช้ร่วมกัน ถ้าต้องเปลี่ยนให้แก้สเปกและ acceptance tests ของงานนั้นพร้อมกัน ทุกการปิดงานต้องแนบ revision และผลทดสอบจริง

## 3. สารบัญและ Required deliverables

| Deliverable | เอกสาร |
|---|---|
| 1 Executive summary | เอกสารนี้ |
| 2 Project audit | [01-audit.md](01-audit.md) |
| 3 Game concept | [02-game-design.md](02-game-design.md) ส่วน Concept |
| 4 Complete GDD | [02-game-design.md](02-game-design.md) ระบบ G01–G20 |
| 5 Disaster and content | [03-content-economy.md](03-content-economy.md) |
| 6 Economy and progression | [03-content-economy.md](03-content-economy.md) |
| 7 World and art | [04-world-ui.md](04-world-ui.md) |
| 8 UI/UX | [04-world-ui.md](04-world-ui.md) |
| 9 Technical architecture | [05-architecture.md](05-architecture.md) |
| 10 Implementation P1–P4 | [06-implementation.md](06-implementation.md) |
| 11 Team execution | [06-implementation.md](06-implementation.md) |
| 12 QA and security | [07-quality-launch.md](07-quality-launch.md) |
| 13 Risk register | [07-quality-launch.md](07-quality-launch.md) |
| 14 Launch readiness | [07-quality-launch.md](07-quality-launch.md) |
| 15 First sprint | [06-implementation.md](06-implementation.md) |

## 4. ข้อกำหนดที่มีผลเหนือเอกสารเก่า

- LOCKED เจ็ดพื้นที่เริ่มต้นคือ **เจ็ดฐานผู้เล่น** แล้ว ไม่ต้องกลับไปถามว่าช่องกลางเป็นฐานหรือไม่ บริการ Hub ต้องมีพื้นที่แยก
- LOCKED Launch มี Tornado Town, Tsunami Coast, Volcanic Ruins, Thunderstorm City และ Inferno Forest เรียงต่อกันจริง Frozen Catastrophe กับ Apocalypse Zone เป็น Post-launch
- LOCKED งานหลักทำใน Studio ผ่าน MCP การ sync ด้วย Rojo เป็นทางเลือก ต้องปิด writer ซ้อนกัน และ export source เพื่อ review ใน Git ทุก handoff
- LOCKED Stabilize/Snatch ไม่เปลี่ยน reward odds ใช้ความเสี่ยงในการหนีเป็นผลต่าง
- LOCKED Global Admin Abuse เลือก Zone แล้วทุก participating server สร้าง Crate ของตนเอง Server ตรวจสิทธิ์ ไม่ให้ client สั่ง Event โดยตรง
- LOCKED งานครั้งนี้จัดทำแผนเท่านั้น ไม่เปลี่ยนสคริปต์ ไม่สร้าง build ไม่เปลี่ยน Place ไม่ Publish และไม่แก้ GitHub

## 5. Product decisions ที่เสนอให้รับรองพร้อมแผน

| ID | คำแนะนำที่เลือก | ผลต่อเกมและทางเลือกที่ไม่เลือก |
|---|---|---|
| D01 | แนว Containment Crew แบบสดใสและขี้เล่น | Horror เต็มรูปแบบทำให้ความอ่านง่ายและภาระ art แย่ลง |
| D02 | 20 species, Common/Rare อย่างละสองตัวต่อ Zone | ได้สองผลลัพธ์ต่อ Rarity จริง ลดการแตก pool ที่มีสมาชิกตัวเดียว |
| D03 | ไม่มี offline income, paid random crates, trading หรือ rebirth ตอน Launch | ลด Inflation, data risk และระบบนอก Core Loop |
| D04 | กล่องที่ยังไม่ข้าม safe exit หายเมื่อหลุด กล่องที่ commit หลัง safe exit กู้ได้ที่จุดเริ่มทางกลับเดิม | กู้ของได้แต่ไม่ใช้ rejoin ข้ามการเดินกลับบ้าน |
| D05 | Theft ของ Disaster ที่วาง เปิดหลังผู้เล่นพ้นการคุ้มครอง พร้อม protected slot แรกและ owner counterplay | ต้องสร้าง transfer escrow ให้ผ่าน fault tests ไม่ลดเป็น client ownership swap |
| D06 | Event ใช้ Rarity เดิม + cosmetic Event variant, Secret tier เลื่อนไปจนมีอย่างน้อยสอง species | ยังมี Special Event Crate แต่ไม่เพิ่มงาน species และรายได้พุ่งโดยไม่จำเป็น |
| D07 | Server capacity เริ่มที่ 7 ผู้เล่น, เก็บ 100 items, วาง 4→8 slots | สอดคล้องเจ็ดฐาน เป็นค่าขอบเขตสำหรับทดสอบ ไม่ใช่ platform limit |
| D08 | Global event ไม่ปลดล็อก Zone ฟรี ผู้ที่เข้าไม่ถึงเห็นเงื่อนไขและ countdown | รักษา progression หลีกเลี่ยงข้อความที่สื่อว่าทุกคนรับของได้แน่ |

การอนุมัติแผนเป็น product gate ตามคำขอของ Head ไม่ใช่การขออนุญาตซ้ำเพื่ออ่านข้อมูล ไม่มีคำถามย่อยที่จำเป็นต้องตอบก่อนอ่านและประเมินชุดนี้

## 6. ข้อสรุปเพื่อเริ่มงาน

Concept ที่แนะนำคือ Containment Crew สถานะจริงยังอยู่ก่อน P1 functional acceptance งานสำคัญสามเรื่องแรกคือ **ยืนยันและ reconcile Studio กับ Git**, **กำหนด durable state/transaction contracts**, และ **ทำ Zone 1 ตั้งแต่ capture ถึง place/collect/rejoin ให้ผ่าน**

Critical path คือ P1-01 → P1-02 → P1-03 → P1-06 → P1-07 → P1-08 → P2-05/P2-06 → P2-08 → P3-02…P3-06 → P3-08 → P4-01…P4-05 → P4-06 ทั้งนี้ P1-04/P1-05 ต้องพร้อมก่อน P1-06 และงานฝึก/ปลดล็อกต้องผ่าน P2-08 เช่นกัน

P1 ส่งลูป PvE และ Save/Recovery ที่ใช้งานได้ P2 ส่ง Progression, Treadmill, Inventory management และ Theft ที่ตรวจ concurrency แล้ว P3 ส่งเจ็ดฐานและห้าโซนงานภาพจริงบน Mobile P4 ส่ง Admin Events, Catch-up, Audit log และ release rehearsal

ตัดจาก Launch คือ Zone 6–7, Boss, Trading, Synergy, Rebirth, Offline income, Paid loot และ roster Secret เต็มชุด เก็บเป็น future backlog โดยไม่ตัดระบบ Locked P1–P4

หลังอนุมัติ ให้เริ่ม P1-01 กับ First sprint ในเอกสารแผน ไม่เริ่มจากสร้างแมพทั้ง Place ใหม่
