const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

exports.scheduleNotification = onSchedule("*/5 * * * *", async (event) => {
  const now = new Date(); // Hora actual en UTC
  const usersRef = admin.firestore().collection("users");

  try {
    const usersSnapshot = await usersRef.get();
    if (usersSnapshot.empty) {
      console.log("No hay usuarios registrados.");
      return;
    }

    // Recorre cada usuario
    for (const userDoc of usersSnapshot.docs) {
      const remindersRef = userDoc.ref.collection("reminders");
      const remindersSnapshot = await remindersRef.get();

      if (remindersSnapshot.empty) {
        console.log(`No hay recordatorios para el usuario ${userDoc.id}.`);
        continue;
      }

      console.log(
        `Recordatorios encontrados para el usuario ${userDoc.id}:`,
        remindersSnapshot.docs.map((doc) => doc.data())
      );

      // Procesa cada recordatorio
      for (const doc of remindersSnapshot.docs) {
        const data = doc.data();
        const { time, medicineName, dose, remainingDays } = data;

        if (!time || !medicineName || !dose || remainingDays === undefined) {
          console.log(`El documento ${doc.id} tiene datos incompletos.`);
          continue;
        }

        try {
          let reminderTime;

          // Manejar `time` como Timestamp o String
          if (time instanceof admin.firestore.Timestamp) {
            reminderTime = time.toDate(); // Convertir Timestamp a Date
          } else if (typeof time === "string") {
            const [hour, minute] = time.split(":").map(Number);
            reminderTime = new Date(
              now.getUTCFullYear(),
              now.getUTCMonth(),
              now.getUTCDate(),
              hour,
              minute
            );
          } else {
            console.log(`Formato de tiempo no válido en el documento ${doc.id}`);
            continue;
          }

          // Calcular diferencia de tiempo en UTC
          const timeDifference = reminderTime - now;

          console.log(`Hora actual (UTC): ${now}`);
          console.log(
            `Hora del recordatorio (UTC): ${reminderTime}, Diferencia (ms): ${timeDifference}`
          );
          

          if (timeDifference >= -60 * 1000 && timeDifference <= 60 * 1000) {
            const payload = {
              notification: {
                title: "Recordatorio de Medicina",
                body: `Toma tu ${medicineName}, Dosis: ${dose}. Quedan ${remainingDays} días.`,
              },
              topic: "reminders",
            };

            await admin.messaging().send(payload);
            console.log(`Notificación enviada para ${medicineName}`);
            

            // Disminuir el contador de días restantes
            if (remainingDays > 1) {
              await doc.ref.update({
                remainingDays: admin.firestore.FieldValue.increment(-1),
              });
              console.log(
                `Días restantes actualizados para ${medicineName}: ${
                  remainingDays - 1
                }`
              );
            } else {
              console.log(
                `Último día para ${medicineName}. No se decrementará más.`
              );
            }
          } else {
            console.log(
              `Recordatorio ${medicineName} no está dentro del rango de los próximos 5 minutos.`
            );
          }
        } catch (error) {
          console.error(`Error procesando el recordatorio ${doc.id}:`, error);
        }
      }
    }
  } catch (error) {
    console.error("Error al enviar notificaciones:", error);
  }
});
