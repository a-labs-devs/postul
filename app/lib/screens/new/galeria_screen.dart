import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';

/// 🖼️ Tela de Galeria de Fotos
/// Visualização de fotos com swipe, zoom e modo fullscreen
class GaleriaScreen extends StatefulWidget {
  final List<String> fotosUrls;
  final int indiceInicial;
  final String? titulo;

  const GaleriaScreen({
    super.key,
    required this.fotosUrls,
    this.indiceInicial = 0,
    this.titulo,
  });

  @override
  State<GaleriaScreen> createState() => _GaleriaScreenState();
}

class _GaleriaScreenState extends State<GaleriaScreen> {
  late PageController _pageController;
  late int _indiceAtual;
  bool _mostrarControles = true;

  @override
  void initState() {
    super.initState();
    _indiceAtual = widget.indiceInicial;
    _pageController = PageController(initialPage: widget.indiceInicial);
  }

  void _alternarControles() {
    setState(() {
      _mostrarControles = !_mostrarControles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Galeria Principal com Photo View
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.fotosUrls[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'foto_$index',
                ),
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 64,
                        ),
                        SizedBox(height: AppSpacing.space16),
                        Text(
                          'Erro ao carregar imagem',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            itemCount: widget.fotosUrls.length,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _indiceAtual = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),

          // Controles de UI
          if (_mostrarControles) ...[
            // AppBar Superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(AppSpacing.space8),
                  child: Row(
                    children: [
                      // Botão Voltar
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                      
                      SizedBox(width: AppSpacing.space12),
                      
                      // Título
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.titulo != null)
                              Text(
                                widget.titulo!,
                                style: AppTypography.titleMedium.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              '${_indiceAtual + 1} de ${widget.fotosUrls.length}',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Botão Compartilhar
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          // TODO: Implementar compartilhamento
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compartilhamento em desenvolvimento'),
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                      
                      SizedBox(width: AppSpacing.space4),
                      
                      // Botão Download
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () {
                          // TODO: Implementar download
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Download em desenvolvimento'),
                            ),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Indicadores Inferiores (Thumbnails)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(AppSpacing.space12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.fotosUrls.length,
                    itemBuilder: (context, index) {
                      final isAtual = index == _indiceAtual;
                      
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          margin: EdgeInsets.only(right: AppSpacing.space8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isAtual
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.3),
                              width: isAtual ? 3 : 1.5,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm - 1),
                            child: Image.network(
                              widget.fotosUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],

          // Botão de Alternar Controles (sempre visível)
          Positioned(
            right: AppSpacing.space16,
            bottom: 120,
            child: FloatingActionButton.small(
              onPressed: _alternarControles,
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              child: Icon(
                _mostrarControles
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
