import 'package:flutter/material.dart';
import 'package:gutrgoopro/profile/model/redeem_model.dart';
import 'package:gutrgoopro/profile/service/redeem_service.dart';

class RedeemCodeBottomSheet {
  static void show(BuildContext context, {required String authToken}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _RedeemSheet(authToken: authToken),
    );
  }
}

class _RedeemSheet extends StatefulWidget {
  final String authToken;
  const _RedeemSheet({required this.authToken});

  @override
  State<_RedeemSheet> createState() => _RedeemSheetState();
}

class _RedeemSheetState extends State<_RedeemSheet> {
  final TextEditingController _codeController = TextEditingController();
  final RedeemService _service = RedeemService();

  bool _isRedeeming = false;
  bool _isLoadingList = false;
  String? _errorMessage;
  String? _successMessage;

  List<RedeemCode> _redeemList = [];
  bool _showList = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeem() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a code');
      return;
    }

    setState(() {
      _isRedeeming = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await _service.redeemCode(widget.authToken, code);
      setState(() {
        _successMessage = result.message;
        _codeController.clear();
      });
    } on RedeemException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Network error. Please try again.');
    } finally {
      setState(() => _isRedeeming = false);
    }
  }

  Future<void> _toggleRedeemList() async {
    if (_showList) {
      setState(() => _showList = false);
      return;
    }

    setState(() {
      _isLoadingList = true;
      _showList = true;
      _errorMessage = null;
    });

    try {
      final list = await _service.getRedeemList(widget.authToken);
      setState(() => _redeemList = list);
    } on RedeemException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load codes.');
    } finally {
      setState(() => _isLoadingList = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Redeem Code',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Enter your code',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon:
                      const Icon(Icons.confirmation_number_outlined, color: Colors.orange),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.orange, width: 1.5),
                  ),
                ),
                onChanged: (_) {
                  if (_errorMessage != null || _successMessage != null) {
                    setState(() {
                      _errorMessage = null;
                      _successMessage = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              if (_errorMessage != null)
                _StatusBanner(
                    message: _errorMessage!, isSuccess: false),
              if (_successMessage != null)
                _StatusBanner(
                    message: _successMessage!, isSuccess: true),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isRedeeming ? null : _handleRedeem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.orange.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isRedeeming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Redeem',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _toggleRedeemList,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showList ? 'Hide Available Codes' : 'View Available Codes',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showList
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ],
                ),
              ),

              if (_showList) ...[
                const SizedBox(height: 16),
                if (_isLoadingList)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  )
                else if (_redeemList.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No codes available',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _redeemList.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Colors.white10,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = _redeemList[index];
                      return _RedeemCodeTile(
                        code: item,
                        onTap: () {
                          _codeController.text = item.code;
                          setState(() => _showList = false);
                        },
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _StatusBanner({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RedeemCodeTile extends StatelessWidget {
  final RedeemCode code;
  final VoidCallback onTap;

  const _RedeemCodeTile({required this.code, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: code.isUsed
              ? Colors.white10
              : Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          code.isUsed ? Icons.lock_outline : Icons.confirmation_number_outlined,
          color: code.isUsed ? Colors.white30 : Colors.orange,
          size: 20,
        ),
      ),
      title: Text(
        code.code,
        style: TextStyle(
          color: code.isUsed ? Colors.white30 : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 1.2,
          decoration:
              code.isUsed ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      subtitle: code.description != null
          ? Text(
              code.description!,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            )
          : null,
      trailing: code.isUsed
          ? const Chip(
              label: Text('Used',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              backgroundColor: Colors.white10,
              padding: EdgeInsets.zero,
            )
          : TextButton(
              onPressed: onTap,
              child: const Text('Use',
                  style: TextStyle(color: Colors.orange, fontSize: 13)),
            ),
    );
  }
}