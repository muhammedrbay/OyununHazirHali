const {onValueUpdated} = require("firebase-functions/v2/database");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();

// 👇 Mevcut Fonksiyonun
exports.resetSonrakiSayfaAndIncreaseCounter = onValueUpdated(
    {
      ref: "/odalar/{odaIsmi}/Sonrakisayfa",
      region: "europe-west1",
    },
    async (event) => {
      const odaIsmi = event.params.odaIsmi;
      const sonrakiSayfa = event.data.after.val();

      const onlineStatusSnapshot = await admin
          .database()
          .ref(`/odalar/${odaIsmi}/onlineStatus`)
          .once("value");
      const onlineStatus = onlineStatusSnapshot.val();

      const combinedList = sonrakiSayfa.map((value, index) => {
        const onlineValue = onlineStatus[index];
        return !(value === false && onlineValue === false);
      });

      const allTrue = combinedList.every((value) => value === true);

      if (allTrue) {
        await new Promise((resolve) => setTimeout(resolve, 1000)); // 1 saniye bekle

        const updates = {};
        updates[`/odalar/${odaIsmi}/Sonrakisayfa`] = sonrakiSayfa.map(() => false);

        const counterRef = admin.database().ref(`/odalar/${odaIsmi}/Counter`);
        const counterSnapshot = await counterRef.once("value");
        const currentCounter = counterSnapshot.val() || 0;
        const newCounter = currentCounter + 1;

        updates[`/odalar/${odaIsmi}/Counter`] = newCounter;

        const lastDigit = newCounter % 10;

        if ([1, 4, 7].includes(lastDigit)) {
          const oylarSnapshot = await admin
              .database()
              .ref(`/odalar/${odaIsmi}/oylar`)
              .once("value");
          const oylar = oylarSnapshot.val();

          if (Array.isArray(oylar)) {
            updates[`/odalar/${odaIsmi}/oylar`] = oylar.map(() => 0);
          }
        }

        return admin.database().ref().update(updates);
      }

      return null;
    },
);

// 👇 Yeni Eklenen Fonksiyon – 2 saatte bir çalışır, eski odaları siler
exports.temizleEskiOdalar = onSchedule(
    {
      schedule: "every 120 minutes", // 2 saatte bir çalışır
      region: "europe-west1",
    },
    async (event) => {
      const now = Date.now();
      const ikiBucukSaat = 2.5 * 60 * 60 * 1000; // 2.5 saat (milisaniye)

      const snapshot = await admin.database().ref("odalar").once("value");
      const odalar = snapshot.val();

      if (!odalar) {
        logger.log("Hiç oda yok.");
        return;
      }

      const silinecekler = {};

      Object.entries(odalar).forEach(([odaIsmi, odaData]) => {
        const girisZamani = odaData.girisZamani || 0;

        if (now - girisZamani > ikiBucukSaat) {
          silinecekler[`odalar/${odaIsmi}`] = null;
        }
      });

      if (Object.keys(silinecekler).length > 0) {
        await admin.database().ref().update(silinecekler);
        logger.log("Silinen odalar:", Object.keys(silinecekler));
      } else {
        logger.log("Silinecek oda bulunamadı.");
      }
    },
);
