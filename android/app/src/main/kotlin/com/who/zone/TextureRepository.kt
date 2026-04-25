package com.who.zone

import io.flutter.view.TextureRegistry
import io.flutter.view.TextureRegistry.SurfaceProducer
import kotlin.collections.iterator

data class TextureProvider(
    val producer:  SurfaceProducer,
    val id: Long,
    val onTexturePopulated: (textureId: Long) -> Unit,
    var isTexturePopulated: Boolean
)

class TextureRepository(
    private val textureRegistry: TextureRegistry,
    private val onTexturePopulated: (textureId: Long) -> Unit
) {
    private var textures = hashMapOf<Long, TextureProvider>()

    fun registerTexture(width: Int, height: Int): TextureProvider {
        val producer = textureRegistry.createSurfaceProducer()
        producer.setSize(width, height)
        val id = producer.id()
        val textureProvider = TextureProvider(producer, id, onTexturePopulated, false)
        textures[id] = textureProvider
        producer.setCallback(object: SurfaceProducer.Callback {
            override fun onSurfaceCleanup() {
                super.onSurfaceCleanup()
            }
        })
        return textureProvider
    }

    fun unregisterTexture(id: Long) : Boolean {
        textures[id]?.let {
            try {
                it.producer.release()
            } catch (_: Throwable) {}
        }
        textures.remove(id)
        return true
    }

    fun getTexture(id: Long) : TextureProvider? {
        return textures[id]
    }

    fun clear() {
        for(it in textures) {
            try {
                it.value.producer.release()
            } catch (_: Throwable) {}
        }
        textures.clear()
    }
}