const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { TranslationServiceClient } = require("@google-cloud/translate");

// Inicializa Firebase Admin
admin.initializeApp();

// Configura opciones globales para mejorar rendimiento
setGlobalOptions({ maxInstances: 10 });

// Inicializa el cliente de traducción de Google
const translationClient = new TranslationServiceClient();

exports.translateTask = onDocumentCreated("tasks/{taskId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.error("Error: No se recibió el snapshot.");
        return;
    }

    const data = snapshot.data();

    // Verificar que title y description existen y no están vacíos
    if (!data?.title?.trim() || !data?.description?.trim()) {
        console.log("No hay título o descripción para traducir.");
        return;
    }

    try {
        // Traducción a inglés
        const [translatedTitleResponse] = await translationClient.translateText({
            parent: `projects/todor5project/locations/global`, // Usa el ID de tu proyecto
            contents: [data.title],
            mimeType: "text/plain",
            targetLanguageCode: "en",
        });

        const [translatedDescriptionResponse] = await translationClient.translateText({
            parent: `projects/todor5project/locations/global`, // Usa el ID de tu proyecto
            contents: [data.description],
            mimeType: "text/plain",
            targetLanguageCode: "en",
        });

        const translatedTitle = translatedTitleResponse.translations[0].translatedText;
        const translatedDescription = translatedDescriptionResponse.translations[0].translatedText;

        // Guardar la traducción en Firestore
        await snapshot.ref.update({
            translatedTitle,
            translatedDescription,
        });

        console.log("Traducción realizada con éxito:", translatedTitle, translatedDescription);
    } catch (error) {
        console.error("Error al traducir:", error);
    }
});