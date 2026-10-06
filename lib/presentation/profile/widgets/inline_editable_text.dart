import 'package:flutter/material.dart';

class InlineEditableText extends StatefulWidget {
  final String initialValue;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final ValueChanged<String> onSubmit;
  final String hintText;
  final int? maxLenght;
  final Color? textColor;

  const InlineEditableText({
    super.key,
    required this.initialValue,
    required this.keyboardType,
    required this.validator,
    required this.onSubmit,
    required this.hintText,
    this.textColor,
    this.maxLenght,
  });
  @override
  State<InlineEditableText> createState() => InlineEditableTextState();
}

class InlineEditableTextState extends State<InlineEditableText> {
  bool editing = false;
  late final controller = TextEditingController(text: widget.initialValue);
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!editing) {
      return InkWell(
        onTap: () => setState(() => editing = true),
        child: Text(
          widget.initialValue.isEmpty ? widget.hintText : widget.initialValue,
          style: TextStyle(
            color: widget.initialValue.isEmpty
                ? Colors.grey
                : widget.textColor ?? Colors.white,
            fontSize: widget.initialValue.isEmpty ? 12 : 15,
            fontWeight: widget.initialValue.isEmpty
                ? FontWeight.w200
                : FontWeight.bold,
            decoration: widget.initialValue.isEmpty
                ? TextDecoration.underline
                : null,
            decorationColor: widget.initialValue.isEmpty
                ? Colors.grey.withAlpha(50)
                : null,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Form(
      key: formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                maxLength: widget.maxLenght,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                controller: controller,
                keyboardType: widget.keyboardType,
                autofocus: true,
                validator: widget.validator,
                onFieldSubmitted: (_) => _confirm(),
                decoration: InputDecoration(
                  errorMaxLines: 2,
                  errorStyle: const TextStyle(fontSize: 12),
                  counterText: '',
                  isDense: true, // ← compacta interno
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            IconButton(
              iconSize: 25,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.check),
              onPressed: _confirm,
            ),
            IconButton(
              iconSize: 25,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.close),
              onPressed: () {
                controller.text = widget.initialValue;
                setState(() => editing = false);
              },
            ), // descarta
          ],
        ),
      ),
    );
  }

  void _confirm() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(controller.text.trim());
    setState(() => editing = false);
  }
}
