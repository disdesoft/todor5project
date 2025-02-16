const { onDocumentWritten } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { TranslationServiceClient } = require("@google-cloud/translate");

// Inicializa Firebase Admin
admin.initializeApp();

// Configura opciones globales para mejorar rendimiento
setGlobalOptions({ maxInstances: 10 });

// Inicializa el cliente de traducción de Google
const translationClient = new TranslationServiceClient();

exports.translateTask = onDocumentWritten("tasks/{taskId}", async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();

    // Verifica si el documento fue eliminado
    if (!afterData) {
        console.log("El documento fue eliminado.");
        return;
    }

    // Verifica si el título o la descripción han cambiado
    const titleChanged = beforeData?.title !== afterData.title;
    const descriptionChanged = beforeData?.description !== afterData.description;

    // Si no hay cambios en el título o la descripción, no hacer nada
    if (!titleChanged && !descriptionChanged) {
        console.log("No hay cambios en el título o la descripción.");
        return;
    }

    // Verifica que title y description existen y no están vacíos
    if (!afterData.title?.trim() || !afterData.description?.trim()) {
        console.log("No hay título o descripción para traducir.");
        return;
    }

    try {
        // Traducción a inglés
        const [translatedTitleResponse] = await translationClient.translateText({
            parent: `projects/todor5project/locations/global`, 
            contents: [afterData.title],
            mimeType: "text/plain",
            targetLanguageCode: "en",
        });

        const [translatedDescriptionResponse] = await translationClient.translateText({
            parent: `projects/todor5project/locations/global`,
            contents: [afterData.description],
            mimeType: "text/plain",
            targetLanguageCode: "en",
        });

        const translatedTitle = translatedTitleResponse.translations[0].translatedText;
        const translatedDescription = translatedDescriptionResponse.translations[0].translatedText;

        // Guarda la traducción en Firestore
        await event.data.after.ref.update({
            translatedTitle,
            translatedDescription,
        });

        console.log("Traducción realizada con éxito:", translatedTitle, translatedDescription);
    } catch (error) {
        console.error("Error al traducir:", error);
    }
});